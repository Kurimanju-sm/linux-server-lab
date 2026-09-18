# 06. 로그 / 시스템 모니터링 실습

## 1. 실습 목표

Linux 시스템에서 발생하는 이벤트와 서비스 동작을 로그를 통해 확인하는 방법을 학습한다.

주요 학습 내용:

- `/var/log` 확인
- `journalctl` 사용
- 서비스별 로그 확인
- `grep`을 이용한 로그 검색
- 실시간 로그 확인
- 오류 로그 확인
- 로그 용량 확인
- Bash를 이용한 로그 점검 스크립트 작성

---

## 2. `/var/log` 확인

Linux에서는 시스템과 여러 프로그램의 로그가 `/var/log`에 저장된다.

```bash
ls -lah /var/log
```

로그 디렉터리의 파일 목록을 확인하였다.

---

## 3. journalctl

systemd 환경에서는 `journald`가 수집한 로그를 `journalctl` 명령으로 확인할 수 있다.

최근 로그 확인:

```bash
sudo journalctl -n 20
```

최근 1시간 로그 확인:

```bash
sudo journalctl --since "1 hour ago"
```

---

## 4. SSH 서비스 로그 확인

SSH 서비스와 관련된 로그를 확인하였다.

```bash
sudo journalctl -u ssh
```

최근 SSH 로그:

```bash
sudo journalctl -u ssh -n 20
```

`-u` 옵션을 사용하면 특정 systemd unit의 로그를 확인할 수 있다.

---

## 5. grep을 이용한 로그 검색

SSH 로그에서 특정 문자열을 검색하였다.

```bash
sudo journalctl -u ssh | grep -i "authentication"
```

인증 성공 관련 로그:

```bash
sudo journalctl -u ssh | grep -i "accepted"
```

인증 실패 관련 로그:

```bash
sudo journalctl -u ssh | grep -i "failed"
```

로그 전체를 확인하는 것보다 필요한 내용을 검색하여 확인할 수 있다.

---

## 6. 실시간 로그 확인

```bash
sudo journalctl -f
```

`-f` 옵션을 사용하면 새로운 로그가 발생할 때 실시간으로 확인할 수 있다.

종료:

```text
Ctrl + C
```

---

## 7. 오류 로그 확인

최근 오류 로그를 확인하였다.

```bash
sudo journalctl -p err -n 20
```

경고 수준까지 확인:

```bash
sudo journalctl -p warning -n 20
```

로그에 오류가 존재하더라도 현재 시스템에 문제가 있다는 의미와 항상 동일하지는 않으므로 로그 내용을 함께 확인해야 한다.

---

## 8. 로그 용량 확인

```bash
sudo du -sh /var/log
```

세부적인 용량 확인:

```bash
sudo du -sh /var/log/* 2>/dev/null | sort -h
```

로그가 지속적으로 쌓일 경우 디스크 공간을 사용할 수 있기 때문에 서버 관리에서는 로그 용량도 확인할 필요가 있다.

---

## 9. 로그 점검 스크립트

`practice/log-check.sh`를 작성하였다.

스크립트에서는 다음 항목을 자동으로 확인하도록 구성하였다.

- `/var/log` 용량
- 최근 시스템 로그
- SSH 서비스 로그
- 최근 오류 로그

실행:

```bash
./log-check.sh
```

---

## 10. 정리

이번 실습을 통해 Linux 시스템에서 발생하는 이벤트를 로그를 통해 확인하는 방법을 학습하였다.

특히 `journalctl`을 사용하면 systemd가 관리하는 서비스의 로그를 확인할 수 있으며, `grep`과 함께 사용하면 필요한 로그만 검색할 수 있다는 것을 확인하였다.

또한 Bash 스크립트를 이용하여 여러 로그 확인 명령을 하나의 점검 도구로 구성하였다.
