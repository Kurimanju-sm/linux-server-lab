# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.# 03. Process & Service Management

Linux 시스템에서 실행 중인 프로세스와 서비스를 확인하고 관리하는 방법을 실습했다.

---

## 1. 학습 목표

- Linux 프로세스의 개념과 구조 이해
- PID와 PPID의 개념 이해
- 실행 중인 프로세스 조회 방법 익히기
- 프로세스 상태 확인
- 백그라운드 프로세스 실행 및 제어
- Signal을 이용한 프로세스 종료
- CPU 및 메모리 사용량 확인
- systemd와 서비스의 관계 이해
- systemctl을 이용한 서비스 제어
- 부모-자식 프로세스 구조 확인

---

## 2. Process란?

프로세스(Process)는 현재 실행 중인 프로그램을 의미한다.

Linux에서는 프로그램이 실행되면 운영체제가 해당 실행 단위에 PID(Process ID)를 부여한다.

프로세스는 CPU, 메모리 등의 시스템 자원을 사용하며 운영체제에 의해 관리된다.

프로세스는 부모-자식 관계를 가질 수 있으며, 이러한 관계를 통해 Linux 시스템의 프로세스 구조를 확인할 수 있다.

---

## 3. ps를 이용한 프로세스 확인

### 3.1 기본 프로세스 확인

현재 터미널에서 실행 중인 프로세스를 확인하기 위해 `ps` 명령어를 사용했다.

```bash
ps
```

실습 과정에서 다음과 같은 프로세스를 확인했다.

```text
PID TTY          TIME CMD
358 pts/0    00:00:01 bash
2569 pts/0    00:00:00 ps
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| TTY | 프로세스가 연결된 터미널 |
| TIME | CPU 사용 시간 |
| CMD | 실행된 명령 |

`ps`를 통해 현재 터미널에서 실행 중인 프로세스를 확인할 수 있었다.

---

## 4. ps aux를 이용한 전체 프로세스 확인

보다 많은 프로세스 정보를 확인하기 위해 `ps aux`를 사용했다.

```bash
ps aux
```

이를 통해 root 및 일반 사용자로 실행되는 프로세스를 확인하고 각 프로세스의 CPU와 메모리 사용량 등을 확인했다.

### 주요 항목

| 항목 | 의미 |
|---|---|
| USER | 프로세스를 실행한 사용자 |
| PID | 프로세스 ID |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| STAT | 프로세스 상태 |
| COMMAND | 실행 중인 명령 |

---

## 5. PID와 PPID

Linux의 각 프로세스에는 PID(Process ID)가 부여된다.

또한 프로세스가 어떤 프로세스에 의해 생성되었는지를 나타내는 PPID(Parent Process ID)가 존재한다.

```bash
ps -ef
```

실습 중 cron 프로세스에서 다음과 같은 관계를 확인했다.

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

여기서:

- `895` → cron 프로세스의 PID
- `1` → 부모 프로세스의 PID
- `root` → 프로세스를 실행한 사용자
- `/usr/sbin/cron` → 실제 실행 중인 프로그램

부모 프로세스의 PID가 `1`이라는 것을 통해 cron 프로세스가 systemd(PID 1)에 의해 관리되는 구조임을 확인했다.

---

## 6. 프로세스 상태

`ps` 명령의 `STAT` 항목을 통해 프로세스의 현재 상태를 확인할 수 있다.

| 상태 | 의미 |
|---|---|
| R | Running - 실행 중 |
| S | Sleeping - 대기 중 |
| D | I/O 대기 |
| T | Stopped - 중지됨 |
| Z | Zombie - 좀비 프로세스 |

실습에서 `sleep` 명령을 실행했을 때 해당 프로세스가 `S` 상태로 표시되는 것을 확인했다.

```bash
sleep 300 &
```

프로세스가 실행 중이지만 실제로 CPU를 계속 사용하는 것이 아니라 일정 시간 동안 대기하고 있기 때문에 `S(Sleeping)` 상태로 나타나는 것을 확인했다.

---

## 7. 백그라운드 프로세스

### 7.1 백그라운드 실행

명령어 뒤에 `&`를 붙이면 프로세스를 백그라운드에서 실행할 수 있다.

```bash
sleep 300 &
```

실행 후 `jobs`를 사용하여 현재 셸에서 실행 중인 백그라운드 작업을 확인했다.

```bash
jobs
```

### 7.2 Foreground로 전환

백그라운드에서 실행 중인 작업을 foreground로 가져오기 위해 `fg`를 사용했다.

```bash
fg %1
```

이후 `Ctrl+C`를 사용하여 foreground에서 실행 중인 `sleep` 프로세스를 종료했다.

이를 통해 foreground와 background 프로세스의 차이를 직접 확인했다.

---

## 8. kill과 Signal

Linux에서 `kill`은 프로세스를 종료하는 명령으로 많이 사용되지만, 실제로는 프로세스에 Signal을 전달하는 명령이다.

### 8.1 SIGTERM

```bash
kill <PID>
```

기본적으로 `kill` 명령은 `SIGTERM(15)`을 전달한다.

SIGTERM은 프로세스에게 종료를 요청하는 Signal이며, 프로세스가 필요한 종료 처리를 수행할 수 있는 기회를 제공한다.

### 8.2 SIGKILL

```bash
kill -9 <PID>
```

`-9`는 `SIGKILL(9)`을 의미한다.

SIGKILL은 프로세스를 즉시 강제로 종료시키며, 프로세스가 종료 처리를 수행할 기회를 주지 않는다.

따라서 일반적인 종료에는 SIGTERM을 먼저 사용하고, 정상적으로 종료되지 않는 경우 SIGKILL을 고려할 수 있다.

### 기타 Signal

```bash
kill -STOP <PID>
kill -CONT <PID>
```

- `SIGSTOP` → 프로세스 실행 중지
- `SIGCONT` → 중지된 프로세스 실행 재개

`kill`은 단순히 프로세스를 삭제하는 명령이 아니라 다양한 Signal을 전달하는 명령이라는 점을 확인했다.

---

## 9. top을 이용한 실시간 자원 확인

프로세스의 실시간 CPU 및 메모리 사용량을 확인하기 위해 `top`을 사용했다.

```bash
top
```

### 주요 항목

| 항목 | 의미 |
|---|---|
| PID | 프로세스 ID |
| USER | 실행 사용자 |
| S | 프로세스 상태 |
| %CPU | CPU 사용률 |
| %MEM | 메모리 사용률 |
| TIME+ | CPU 사용 시간 |
| COMMAND | 실행 명령 |

`top`을 이용하면 어떤 프로세스가 CPU나 메모리를 많이 사용하는지 실시간으로 확인할 수 있다.

---

## 10. CPU 부하 테스트

특정 프로세스가 CPU 자원을 많이 사용할 경우 `top`에서 어떻게 나타나는지 확인하기 위해 `yes` 명령을 사용했다.

```bash
yes > /dev/null &
```

`yes`는 반복적으로 데이터를 출력하는 명령이다.

출력을 `/dev/null`로 보내 화면에 출력되는 내용은 버리고 CPU 사용량을 관찰했다.

`top`에서 다음과 같이 CPU 사용량이 높은 `yes` 프로세스를 확인할 수 있었다.

```text
PID     USER       %CPU   %MEM   COMMAND
3199    stave123   99.7    0.2   yes
```

실습 결과 `yes` 프로세스가 CPU를 거의 100% 사용하는 반면 메모리 사용량은 상대적으로 낮게 나타나는 것을 확인했다.

이를 통해 프로세스마다 시스템 자원 사용 형태가 다를 수 있다는 것을 확인했다.

실습 후 다음 명령으로 `yes` 프로세스를 종료했다.

```bash
pkill yes
```

---

## 11. systemd

Linux 시스템에서는 `systemd`가 시스템의 다양한 서비스와 프로세스를 관리한다.

다음 명령으로 systemd의 상태를 확인했다.

```bash
systemctl status
```

실습 환경에서 systemd의 PID가 `1`인 것을 확인했다.

```text
/sbin/init
```

또한 `cron.service`, `dbus.service`, `rsyslog.service` 등의 서비스가 systemd에 의해 관리되는 것을 확인했다.

---

## 12. Service와 Process의 차이

서비스(Service)는 시스템에서 특정 기능을 제공하기 위해 지속적으로 관리되는 프로그램 단위이다.

프로세스(Process)는 실제로 실행 중인 프로그램의 실행 단위이다.

예를 들어 `cron.service`는 서비스 관리 단위이며, 실제 실행되고 있는 프로그램은 다음과 같은 프로세스이다.

```text
cron.service
    ↓
/usr/sbin/cron
```

즉, 서비스는 관리 대상 및 실행 단위를 의미하고 프로세스는 실제 실행되고 있는 프로그램이라고 이해할 수 있다.

---

## 13. systemctl을 이용한 서비스 관리

### 13.1 서비스 상태 확인

```bash
systemctl status cron
```

특정 서비스의 실행 상태를 확인할 수 있다.

### 13.2 서비스 중지

```bash
sudo systemctl stop cron
```

실습에서는 `cron.service`를 직접 중지한 후 상태를 확인했다.

중지 후 서비스가 `inactive` 상태가 되는 것을 확인했다.

### 13.3 서비스 시작

중지한 cron 서비스를 다시 시작했다.

```bash
sudo systemctl start cron
```

이후:

```bash
systemctl status cron
```

을 실행하여 서비스가 다시 `active (running)` 상태로 정상적으로 실행되는 것을 확인했다.

이를 통해 `systemctl`을 이용한 서비스의 상태 확인, 중지, 시작 과정을 직접 실습했다.

---

## 14. 서비스와 프로세스 연결 확인

cron 서비스가 실제로 어떤 프로세스로 실행되는지 확인하기 위해 다음 명령을 사용했다.

```bash
ps -ef | grep '[c]ron'
```

실습 결과:

```text
root         895       1  0 22:30 ?        00:00:00 /usr/sbin/cron -f -P
```

이를 통해 다음과 같은 관계를 확인했다.

```text
systemd (PID 1)
    │
    └── cron.service
            │
            └── /usr/sbin/cron
                PID = 895
```

`systemctl`에서 관리하는 서비스와 `ps`에서 확인하는 실제 프로세스가 서로 연결되어 있다는 것을 확인했다.

---

## 15. pstree를 이용한 프로세스 구조 확인

프로세스의 부모-자식 관계를 시각적으로 확인하기 위해 `pstree`를 사용했다.

```bash
pstree -p 1
```

출력에서 `cron(895)`가 systemd(PID 1)의 하위 프로세스로 표시되는 것을 확인했다.

이를 통해 Linux 시스템의 프로세스가 계층적인 구조로 구성되어 있다는 것을 확인했다.

개념적으로 다음과 같은 구조로 이해할 수 있다.

```text
systemd (PID 1)
    │
    ├── cron
    ├── dbus
    ├── rsyslog
    └── 기타 프로세스
```

---

## 16. 실습을 통해 확인한 내용

이번 실습에서는 Linux 프로세스와 서비스의 기본적인 관리 방법을 직접 확인했다.

### Process

- `ps`를 이용한 프로세스 조회
- `ps aux`를 이용한 전체 프로세스 확인
- PID와 PPID 확인
- 프로세스 상태 확인
- 백그라운드 프로세스 실행
- `jobs`, `fg`를 이용한 작업 제어
- `kill`을 이용한 Signal 전달
- `top`을 이용한 CPU 및 메모리 사용량 확인

### Resource

- `yes`를 이용한 CPU 부하 테스트
- CPU 사용률과 메모리 사용률 비교

### Service

- systemd의 역할 확인
- `systemctl status`를 이용한 서비스 상태 확인
- `systemctl stop`을 이용한 서비스 중지
- `systemctl start`를 이용한 서비스 시작
- 서비스와 실제 프로세스의 관계 확인
- `pstree`를 이용한 부모-자식 프로세스 구조 확인

---

## 17. 핵심 정리

Linux에서는 프로그램이 실행되면 프로세스가 생성되고 PID가 부여된다.

각 프로세스는 부모 프로세스와 연결될 수 있으며, `ps`, `top`, `pstree` 등의 명령어를 통해 프로세스의 상태와 구조를 확인할 수 있다.

또한 Linux 시스템에서는 `systemd`가 여러 서비스를 관리하며, `systemctl`을 통해 서비스의 상태를 확인하거나 시작 및 중지할 수 있다.

이번 실습에서는 다음과 같은 Linux 시스템 관리 구조를 직접 확인했다.

```text
systemd
   ↓
service
   ↓
process
   ↓
PID
```

프로세스 관리 명령어와 서비스 관리 명령어를 함께 사용하면서 Linux 시스템에서 실행 중인 프로그램이 어떻게 관리되는지 이해하는 것을 목표로 했다.
