# [패치] n8n 부팅시 node.exe 빈창 없애는 방법

이 현상을 해결하려면 n8n의 소스 코드 중 하위 프로세스를 실행(spawn)하는 부분에 

```javascript
windowsHide: true
```

 옵션을 추가해야 합니다.



패치해야 할 파일은 총 2개입니다.

### 1. JavaScript Task Runner 패치

파일 경로: 

c:\n8n\n8n-instance\node_modules\n8n\dist\task-runners\task-runner-process-js.js



**수정 전:**

javascript

```javascript
return (0, node_child_process_1.spawn)('node', [...flags, startScript], {
    env: this.getProcessEnvVars(grantToken, taskBrokerUri),
});
```

**수정 후:**

javascript

```javascript
return (0, node_child_process_1.spawn)('node', [...flags, startScript], {
    env: this.getProcessEnvVars(grantToken, taskBrokerUri),
    windowsHide: true, // 이 줄을 추가
});
```

### 2. Python Task Runner 패치 (필요한 경우)

파일 경로: 

c:\n8n\n8n-instance\node_modules\n8n\dist\task-runners\task-runner-process-py.js



**수정 전:**

javascript

```javascript
return (0, node_child_process_1.spawn)(venvPath, ['-m', 'src.main'], {
    cwd: pythonDir,
    env: {
        // ... 생략 ...
    },
});
```

**수정 후:**

javascript

```javascript
return (0, node_child_process_1.spawn)(venvPath, ['-m', 'src.main'], {
    cwd: pythonDir,
    env: {
        // ... 생략 ...
    },
    windowsHide: true, // 이 줄을 추가
});
```

------

### ⚠️ 주의사항

이 파일들은 

```
node_modules
```

 폴더 안에 있으므로, **n8n을 업데이트하거나 `npm install`을 다시 실행하면 수정 사항이 초기화됩니다.**

(수정 후에는 n8n을 재시작해야 적용됩니다.)