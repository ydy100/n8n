# 실행 정책 및 출력 인코딩 설정
if ((Get-ExecutionPolicy) -ne 'RemoteSigned') {
    Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process -Force
}
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$form = New-Object System.Windows.Forms.Form
$form.Text = "n8n PM2 자동 실행 관리자"
$form.Size = New-Object System.Drawing.Size(450, 350)
$form.StartPosition = "CenterScreen"
$form.FormBorderStyle = "FixedDialog"
$form.MaximizeBox = $false
$form.Font = New-Object System.Drawing.Font("맑은 고딕", 9)

$label = New-Object System.Windows.Forms.Label
$label.Text = "n8n(PM2)의 윈도우 부팅 시 자동 실행을 관리합니다."
$label.Location = New-Object System.Drawing.Point(20, 20)
$label.Size = New-Object System.Drawing.Size(400, 40)
$form.Controls.Add($label)

$btnRegister = New-Object System.Windows.Forms.Button
$btnRegister.Text = "자동 실행 등록 (Silent Register)"
$btnRegister.Location = New-Object System.Drawing.Point(50, 80)
$btnRegister.Size = New-Object System.Drawing.Size(330, 45)
$btnRegister.BackColor = [System.Drawing.Color]::LightGreen
$btnRegister.Add_Click({
    try {
        # 1. PM2 실행 파일의 전체 경로 확보 (가장 중요)
        $pm2Path = (Get-Command pm2.cmd -ErrorAction SilentlyContinue).Source
        if (-not $pm2Path) {
            $pm2Path = "$env:AppData\npm\pm2.cmd"
        }

        # 2. 기존의 모든 PM2 관련 자동 실행 항목 제거 (충돌 방지)
        $regPath = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
        $oldNames = @("PM2", "pm2", "n8n-PM2-Silent")
        foreach ($name in $oldNames) {
            if (Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $regPath -Name $name -Force
            }
        }

        # 3. 무음 실행을 위한 VBS 스크립트 생성 (절대 경로 사용)
        $vbsPath = "C:\n8n\n8n-resurrect.vbs"
        $vbsContent = "Set WshShell = CreateObject(`"WScript.Shell`")" + "`r`n" + `
                      "WshShell.Run `"cmd /c `"`"$pm2Path`"`" resurrect`", 0, False"
        $vbsContent | Out-File -FilePath $vbsPath -Encoding ascii -Force

        # 4. 레지스트리에 새로 등록
        Set-ItemProperty -Path $regPath -Name "n8n-PM2-Silent" -Value "wscript.exe `"$vbsPath`""

        # 5. 현재 PM2 상태 저장
        if (Test-Path $pm2Path) {
            & $pm2Path save
        } else {
            pm2 save
        }

        [System.Windows.Forms.MessageBox]::Show("창 없는 자동 실행 등록이 완료되었습니다!`n`n이제 재부팅 시 검은 창 없이 n8n이 백그라운드에서 실행됩니다.", "성공")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("오류 발생: $($_.Exception.Message)", "오류")
    }
})
$form.Controls.Add($btnRegister)

$btnUnregister = New-Object System.Windows.Forms.Button
$btnUnregister.Text = "자동 실행 해제 (Unregister)"
$btnUnregister.Location = New-Object System.Drawing.Point(50, 140)
$btnUnregister.Size = New-Object System.Drawing.Size(330, 45)
$btnUnregister.BackColor = [System.Drawing.Color]::LightPink
$btnUnregister.Add_Click({
    try {
        # 1. 모든 관련 레지스트리 항목 삭제
        $regPath = "Registry::HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Run"
        $oldNames = @("PM2", "pm2", "n8n-PM2-Silent")
        foreach ($name in $oldNames) {
            if (Get-ItemProperty -Path $regPath -Name $name -ErrorAction SilentlyContinue) {
                Remove-ItemProperty -Path $regPath -Name $name -Force
            }
        }

        # 2. 기존 패키지 방식(pm2-startup) 해제 시도
        if (Get-Command pm2-startup -ErrorAction SilentlyContinue) {
            pm2-startup uninstall | Out-Null
        }

        # 3. VBS 파일 삭제
        $vbsPath = "C:\n8n\n8n-resurrect.vbs"
        if (Test-Path $vbsPath) {
            Remove-Item $vbsPath -Force
        }

        [System.Windows.Forms.MessageBox]::Show("자동 실행 설정이 완전히 해제되었습니다.", "완료")
    } catch {
        [System.Windows.Forms.MessageBox]::Show("오류 발생: $($_.Exception.Message)", "오류")
    }
})
$form.Controls.Add($btnUnregister)

$btnStatus = New-Object System.Windows.Forms.Button
$btnStatus.Text = "현재 PM2 상태 확인"
$btnStatus.Location = New-Object System.Drawing.Point(50, 200)
$btnStatus.Size = New-Object System.Drawing.Size(330, 45)
$btnStatus.Add_Click({
    # PM2 출력을 표 형식으로 가져오기
    $status = pm2 status --no-color | Out-String

    # 결과 폼 생성
    $statusForm = New-Object System.Windows.Forms.Form
    $statusForm.Text = "PM2 프로세스 상태 (표 형식)"
    $statusForm.Size = New-Object System.Drawing.Size(1200, 500)
    $statusForm.StartPosition = "CenterParent"

    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Multiline = $true
    $textBox.ReadOnly = $true
    $textBox.WordWrap = $false
    $textBox.ScrollBars = "Both"
    $textBox.Dock = "Fill"
    $textBox.Font = New-Object System.Drawing.Font("Consolas", 10)
    $textBox.Text = $status

    # 자동 선택 해제: 포커스를 텍스트 박스에서 제거하거나 선택 영역을 초기화
    $statusForm.Add_Shown({
        $textBox.SelectionLength = 0
        $statusForm.ActiveControl = $null
    })

    $statusForm.Controls.Add($textBox)
    $statusForm.ShowDialog()
})
$form.Controls.Add($btnStatus)

$btnClose = New-Object System.Windows.Forms.Button
$btnClose.Text = "닫기"
$btnClose.Location = New-Object System.Drawing.Point(170, 260)
$btnClose.Size = New-Object System.Drawing.Size(100, 30)
$btnClose.Add_Click({ $form.Close() })
$form.Controls.Add($btnClose)

$form.ShowDialog()
