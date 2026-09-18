# 05. SSH 실습

## 1. 실습 목표

- SSH의 기본 개념 이해
- OpenSSH 서버 설치 및 상태 확인
- SSH 기본 포트(22/tcp) 확인
- localhost를 이용한 SSH 접속 실습
- SSH 공개키/개인키 구조 이해
- 공개키 인증 설정 및 테스트
- systemd와 SSH socket activation 이해
- SSH 서비스 장애 상황 및 복구 실습
- sshd 설정과 실제 적용 설정 확인
- SSH 접속 로그 및 verbose 모드 확인

---

## 2. SSH 서버 설치 확인

### 확인

```bash
sudo systemctl status ssh
```

### 설치 전 결과

```text
Unit ssh.service could not be found.
```

SSH 서버가 설치되어 있지 않은 상태를 확인하였다.

### SSH 서버 설치

```bash
sudo apt update
sudo apt install openssh-server -y
```

OpenSSH 서버를 설치하였다.

### 설치 후

```bash
sudo systemctl status ssh
```

SSH 서비스가 정상적으로 설치된 것을 확인하였다.

---

## 3. SSH 포트 확인

```bash
sudo ss -tlnp
```

확인 결과:

```text
0.0.0.0:22
[::]:22
```

SSH의 기본 TCP 포트인 22번 포트가 LISTEN 상태인 것을 확인하였다.

다만 프로세스는 `sshd`가 직접 표시되지 않고 `systemd`로 표시되었다.

이는 현재 환경에서 SSH socket activation이 사용되고 있기 때문이다.

---

## 4. SSH localhost 접속

현재 WSL 환경에서 자기 자신에게 SSH 접속을 수행하였다.

```bash
ssh localhost
```

SSH 로그인에 성공하였으며 다음 명령으로 접속 계정을 확인하였다.

```bash
whoami
```

결과:

```text
user
```

SSH를 이용해 새로운 셸 세션이 생성되는 것을 확인하였다.

접속 종료:

```bash
exit
```

---

## 5. SSH 키 확인

현재 사용자 홈 디렉터리의 SSH 키를 확인하였다.

```bash
ls -la ~/.ssh
```

기존 Ed25519 키가 존재하는 것을 확인하였다.

주요 파일:

```text
id_ed25519
id_ed25519.pub
```

### 키의 역할

- `id_ed25519`: 개인키
- `id_ed25519.pub`: 공개키

개인키는 외부에 공개하지 않고 안전하게 보관해야 하며,
공개키는 SSH 서버에 등록하여 인증에 사용할 수 있다.

---

## 6. 공개키 인증 설정

`ssh-copy-id`를 이용하여 현재 사용자의 공개키를 localhost SSH 서버에 등록하였다.

```bash
ssh-copy-id localhost
```

최초 실행 시 현재 Linux 사용자의 비밀번호를 입력하였다.

결과:

```text
Number of key(s) added: 1
```

공개키가 SSH 서버에 등록되었다.

이후 동일한 명령을 다시 실행하였을 때:

```text
WARNING: All keys were skipped because they already exist on the remote system.
```

메시지가 출력되었다.

이는 오류가 아니라 이미 동일한 공개키가 서버에 등록되어 있기 때문에 추가 등록을 하지 않았다는 의미이다.

---

## 7. 공개키 인증 테스트

```bash
ssh localhost
```

공개키 인증을 이용하여 localhost에 SSH 접속하였다.

접속 후:

```bash
whoami
```

를 통해 현재 사용자가 `user`임을 확인하였다.

접속 종료:

```bash
exit
```

공개키 인증이 정상적으로 동작하는 것을 확인하였다.

---

## 8. SSH socket activation 확인

SSH 서비스 상태를 확인하였다.

```bash
sudo systemctl status ssh
```

서비스를 중지한 후:

```bash
sudo systemctl stop ssh
```

상태를 다시 확인하였다.

```text
Active: inactive (dead)
TriggeredBy: ssh.socket
```

`ssh.service`가 중지된 상태에서도 `ssh.socket`이 SSH 연결을 기다리는 구조임을 확인하였다.

이 상태에서:

```bash
ssh localhost
```

를 실행하자 SSH 접속이 다시 정상적으로 이루어졌다.

### 동작 구조

```text
ssh.socket
    ↓
TCP 22번 포트에서 연결 대기
    ↓
SSH 접속 요청 발생
    ↓
systemd가 ssh.service 활성화
    ↓
sshd 실행
    ↓
SSH 인증 및 로그인
```

이를 통해 systemd socket activation의 동작 방식을 확인하였다.

---

## 9. SSH socket 중지 및 복구

SSH socket까지 중지하였다.

```bash
sudo systemctl stop ssh.socket
```

상태 확인:

```bash
sudo systemctl status ssh.socket
```

TCP 22번 포트의 상태를 확인하였다.

```bash
sudo ss -tlnp | grep ':22'
```

이후 SSH socket을 다시 시작하여 서비스를 복구하였다.

```bash
sudo systemctl start ssh.socket
```

SSH 접속을 다시 테스트하여 정상적으로 연결되는 것을 확인하였다.

```bash
ssh localhost
```

---

## 10. SSH 설정 확인

SSH 서버 설정 파일을 확인하였다.

```bash
sudo cat /etc/ssh/sshd_config
```

설정 파일에서 주요 항목을 확인하였다.

또한 실제 SSH 서버가 적용하고 있는 최종 설정을 확인하였다.

```bash
sudo sshd -T | grep -E '^(port|pubkeyauthentication|passwordauthentication|permitrootlogin)'
```

확인 결과:

```text
port 22
permitrootlogin prohibit-password
pubkeyauthentication yes
passwordauthentication yes
```

### 설정 해석

#### port 22

SSH 서버가 TCP 22번 포트를 사용한다.

#### pubkeyauthentication yes

공개키 인증을 허용한다.

#### passwordauthentication yes

비밀번호 인증도 허용한다.

#### permitrootlogin prohibit-password

root 계정의 비밀번호를 이용한 SSH 로그인을 허용하지 않는다.

---

## 11. sshd_config와 sshd -T의 차이

`/etc/ssh/sshd_config`에서 특정 설정이 직접 활성화되어 있지 않더라도
SSH 서버는 기본값을 적용할 수 있다.

따라서 다음 명령을 통해 실제 SSH 서버가 적용하는 최종 설정을 확인하였다.

```bash
sudo sshd -T
```

`sshd -T`는 설정 파일과 기본값 등을 반영한 SSH 서버의 유효 설정을 확인하는 데 사용할 수 있다.

---

## 12. SSH verbose 모드

SSH 연결 과정을 자세하게 확인하기 위해 verbose 모드를 사용하였다.

```bash
ssh -v localhost
```

verbose 출력에서 SSH 키를 이용한 인증 과정과 서버 인증 결과를 확인하였다.

SSH 공개키 인증이 실제 접속 과정에서 사용되는 것을 확인하였다.

---

## 13. SSH 문제 해결 과정

이번 실습에서 확인한 기본적인 SSH troubleshooting 흐름은 다음과 같다.

```text
1. SSH 서비스 상태 확인
        ↓
2. SSH socket 상태 확인
        ↓
3. TCP 22번 포트 LISTEN 여부 확인
        ↓
4. localhost SSH 접속 테스트
        ↓
5. 공개키 인증 여부 확인
        ↓
6. sshd 설정 확인
        ↓
7. 필요 시 서비스/socket 재시작
        ↓
8. SSH 재접속으로 정상 여부 확인
```

---

## 14. 실습 결과

이번 실습을 통해 다음 내용을 확인하였다.

- OpenSSH 서버 설치 방법
- systemctl을 이용한 SSH 서비스 상태 확인
- TCP 22번 포트 확인
- localhost SSH 접속
- SSH 공개키/개인키 구조
- ssh-copy-id를 이용한 공개키 등록
- 공개키 인증을 이용한 SSH 접속
- systemd의 socket activation 구조
- SSH socket과 SSH service의 관계
- SSH 서비스 및 socket 중지/복구
- sshd_config 확인
- `sshd -T`를 이용한 실제 적용 설정 확인
- `ssh -v`를 이용한 SSH 인증 과정 확인

특히 SSH 서비스가 `inactive (dead)` 상태이더라도
`ssh.socket`이 활성화되어 있으면 접속 요청에 의해
SSH 서비스가 다시 활성화될 수 있다는 점을 직접 확인하였다.

이를 통해 SSH를 단순한 원격 접속 명령어가 아니라
서비스, 소켓, 포트, 인증 및 systemd가 연결된 하나의 서버 운영 요소로 이해할 수 있었다.
