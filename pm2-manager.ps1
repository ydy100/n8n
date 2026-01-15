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
$btnRegister.Text = "자동 실행 등록 (Register)"
$btnRegister.Location = New-Object System.Drawing.Point(50, 80)
$btnRegister.Size = New-Object System.Drawing.Size(330, 45)
$btnRegister.BackColor = [System.Drawing.Color]::LightGreen
$btnRegister.Add_Click({
    try {
        npm install -g pm2-windows-startup
        pm2-startup install
        pm2 save
        [System.Windows.Forms.MessageBox]::Show("자동 실행 등록이 완료되었습니다!", "성공")
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
        pm2-startup uninstall
        [System.Windows.Forms.MessageBox]::Show("자동 실행 설정이 해제되었습니다.", "완료")
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