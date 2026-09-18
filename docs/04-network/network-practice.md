# 04. Network Practice

## 1. 학습 목표

- Linux에서 네트워크 인터페이스와 IP 주소 확인
- CIDR을 이용한 네트워크 대역 확인
- 기본 게이트웨이와 라우팅 테이블 확인
- 외부 IP 통신 확인
- DNS 이름 해석 확인
- HTTP/HTTPS 통신 확인
- TCP 포트와 LISTEN 상태 확인
- Python HTTP 서버 실행
- 서버 장애 상황을 재현하고 원인을 확인
- 서비스 재실행을 통한 복구 과정 확인

---

## 2. 네트워크 인터페이스 확인

### 명령어

```bash
ip addr
```

### 주요 결과

```text
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500
    inet 172.31.29.31/20 brd 172.31.31.255 scope global eth0
```

현재 WSL의 주요 네트워크 인터페이스는 `eth0`이며,

- IP: `172.31.29.31`
- Prefix: `/20`
- Broadcast: `172.31.31.255`

를 확인했다.

---

## 3. CIDR 및 네트워크 대역 확인

`/20`의 서브넷 마스크는 다음과 같다.

```text
/20
11111111.11111111.11110000.00000000

= 255.255.240.0
```

현재 IP가 `172.31.29.31/20`이므로 네트워크 주소는:

```text
172.31.16.0/20
```

이다.

네트워크 범위:

```text
Network    : 172.31.16.0
Usable     : 172.31.16.1 ~ 172.31.31.254
Broadcast  : 172.31.31.255
```

---

## 4. 라우팅 테이블 확인

### 명령어

```bash
ip route
```

### 결과

```text
default via 172.31.16.1 dev eth0 proto kernel
172.31.16.0/20 dev eth0 proto kernel scope link src 172.31.29.31
```

기본 게이트웨이는 다음과 같이 확인되었다.

```text
172.31.16.1
```

또한 현재 네트워크가 `172.31.16.0/20`으로 설정되어 있는 것을 확인했다.

---

## 5. 기본 게이트웨이 통신 확인

### 명령어

```bash
ping -c 4 $(ip route | awk '/default/ {print $3}')
```

### 결과

```text
PING 172.31.16.1 (172.31.16.1) 56(84) bytes of data.

--- 172.31.16.1 ping statistics ---
4 packets transmitted, 0 received, 100% packet loss
```

기본 게이트웨이 `172.31.16.1`에 대한 ICMP 응답은 확인되지 않았다.

하지만 이 결과만으로 네트워크 전체가 정상적으로 동작하지 않는다고 판단할 수는 없기 때문에 외부 IP에 대한 통신을 추가로 확인했다.

---

## 6. 외부 IP 통신 확인

### 명령어

```bash
ping -c 4 1.1.1.1
```

외부 IP 통신이 정상적으로 가능한 것을 확인했다.

따라서 기본 게이트웨이의 ICMP 응답이 없었지만 외부 네트워크까지의 통신 자체는 정상적으로 동작하고 있음을 확인했다.

---

## 7. DNS 이름 해석 확인

### 명령어

```bash
getent hosts google.com
```

### 결과

```text
2404:6800:400a:1000::65 google.com
2404:6800:400a:1000::8a google.com
2404:6800:400a:1000::71 google.com
2404:6800:400a:1000::8b google.com
```

`google.com`에 대한 IP 주소가 반환되는 것을 확인했다.

DNS 이름 해석이 정상적으로 동작하는 것을 확인했다.

---

## 8. DNS + ICMP 통신 확인

### 명령어

```bash
ping -c 4 google.com
```

### 결과

```text
PING google.com (172.217.209.102) 56(84) bytes of data.
64 bytes from hq-in-f102.1e100.net (172.217.209.102): icmp_seq=1 ttl=110 time=46.4 ms
64 bytes from hq-in-f102.1e100.net (172.217.209.102): icmp_seq=2 ttl=110 time=46.2 ms
64 bytes from hq-in-f102.1e100.net (172.217.209.102): icmp_seq=3 ttl=110 time=46.5 ms
64 bytes from hq-in-f102.1e100.net (172.217.209.102): icmp_seq=4 ttl=110 time=46.8 ms

--- google.com ping statistics ---
4 packets transmitted, 4 received, 0% packet loss
rtt min/avg/max/mdev = 46.204/46.492/46.842/0.231 ms
```

`google.com`이 IPv4 주소 `172.217.209.102`로 해석되었으며,

- 전송: 4
- 수신: 4
- Packet Loss: 0%
- 평균 RTT: 약 46.5ms

를 확인했다.

---

## 9. HTTPS 통신 확인

### 명령어

```bash
curl -I https://google.com
```

### 주요 결과

```text
HTTP/2 301
location: https://www.google.com/
content-type: text/html; charset=UTF-8
server: gws
```

Google 서버로 HTTPS 요청을 보냈으며 `HTTP/2 301` 응답을 확인했다.

`301`은 Google이 `https://www.google.com/`으로 이동하도록 안내하는 HTTP 리다이렉션 응답이다.

이를 통해 단순한 ICMP 통신뿐만 아니라 실제 HTTPS 요청과 HTTP 응답까지 정상적으로 이루어지는 것을 확인했다.

---

## 10. Python HTTP 서버 실행

네트워크 실습을 위해 직접 HTTP 서버를 실행했다.

### 서버 디렉터리 생성

```bash
mkdir -p ~/network-practice/web
echo "Network Practice Server" > ~/network-practice/web/index.html
cd ~/network-practice/web
```

### HTTP 서버 실행

```bash
python3 -m http.server 8080
```

Python HTTP 서버를 TCP `8080` 포트에서 실행했다.

---

## 11. 로컬 HTTP 통신 확인

다른 터미널에서 다음 명령어를 실행했다.

```bash
curl http://127.0.0.1:8080
```

### 결과

```text
Network Practice Server
```

`127.0.0.1:8080`으로 HTTP 요청을 보내 Python HTTP 서버가 생성한 `index.html`의 내용을 정상적으로 반환하는 것을 확인했다.

통신 흐름:

```text
curl
 ↓
127.0.0.1:8080
 ↓
TCP 8080
 ↓
Python HTTP Server
 ↓
index.html
 ↓
HTTP 응답
```

---

## 12. TCP 포트 상태 확인

### 명령어

```bash
ss -tlnp | grep 8080
```

### 결과

```text
LISTEN 0      5      0.0.0.0:8080      0.0.0.0:*
users:(("python3",pid=1241,fd=3))
```

다음 내용을 확인했다.

- `LISTEN`: 8080 포트에서 연결 대기 중
- `0.0.0.0:8080`: 모든 IPv4 인터페이스에서 8080 포트를 사용
- `python3`: 해당 포트를 사용 중인 프로세스
- PID: `1241`
- FD: `3`

즉 Python 프로세스가 실제로 TCP `8080` 포트를 열고 LISTEN 상태로 동작하고 있음을 확인했다.

---

## 13. HTTP 서버 장애 상황 재현

Python HTTP 서버를 종료한 후 다음 명령어로 서버 상태를 확인했다.

```bash
ss -tlnp | grep 8080
```

8080 포트가 LISTEN 상태가 아닌 것을 확인했다.

이후 Python 프로세스도 확인했다.

```bash
ps aux | grep '[p]ython3'
```

### 결과

```text
root  118 ... /usr/bin/python3 /usr/bin/networkd-dispatcher --run-startup-triggers
root  254 ... /usr/bin/python3 /usr/share/unattended-upgrades/unattended-upgrade-shutdown --wait-for-signal
```

시스템에서 Python을 사용하는 다른 프로세스는 존재했지만,

```text
python3 -m http.server 8080
```

으로 실행했던 HTTP 서버 프로세스는 존재하지 않았다.

이를 통해 8080 포트 접속 장애의 원인이 해당 HTTP 서버 프로세스가 종료된 것임을 확인했다.

---

## 14. HTTP 서버 복구

다시 서버 디렉터리에서 다음 명령어를 실행했다.

```bash
python3 -m http.server 8080
```

이후 다른 터미널에서:

```bash
curl http://127.0.0.1:8080
```

실행하여 다시 다음 결과를 확인했다.

```text
Network Practice Server
```

그리고:

```bash
ss -tlnp | grep 8080
```

으로 8080 포트가 다시 `LISTEN` 상태가 된 것을 확인했다.

---

## 15. 트러블슈팅 과정

이번 실습에서는 로컬 HTTP 서버의 접속 장애를 의도적으로 발생시킨 후 원인을 확인하고 복구했다.

```text
HTTP 접속 실패
      ↓
8080 포트 상태 확인
      ↓
LISTEN 상태 확인
      ↓
Python 프로세스 확인
      ↓
HTTP 서버 프로세스 종료 확인
      ↓
Python HTTP 서버 재실행
      ↓
8080 포트 LISTEN 확인
      ↓
curl 접속
      ↓
정상 응답 확인
```

단순히 접속 실패를 네트워크 문제로 판단하지 않고,

```text
포트 상태
   ↓
프로세스 상태
   ↓
서비스 상태
```

를 순서대로 확인하여 원인을 좁혀가는 과정을 실습했다.

---

## 16. 실습 결과

이번 실습을 통해 다음 항목을 직접 확인했다.

- `ip addr`를 이용한 네트워크 인터페이스 및 IP 확인
- `/20` CIDR을 이용한 네트워크 대역 계산
- `ip route`를 이용한 라우팅 테이블 확인
- 기본 게이트웨이 ICMP 응답 여부 확인
- 외부 IP 통신 확인
- DNS 이름 해석 확인
- `ping`을 이용한 네트워크 연결 상태 확인
- `curl`을 이용한 HTTPS 통신 확인
- Python HTTP 서버 실행
- TCP 8080 포트 LISTEN 상태 확인
- `ss`를 이용한 포트와 프로세스 확인
- `ps`를 이용한 프로세스 상태 확인
- HTTP 서버 장애 상황 재현
- 장애 원인 확인 및 서버 재실행
- 복구 후 HTTP 통신 정상 여부 확인

특히 네트워크 장애 상황에서 무조건 네트워크 문제라고 판단하지 않고,

**IP → Routing → DNS → Port → Process → Application**

순서로 상태를 확인하며 문제 범위를 좁혀가는 기본적인 트러블슈팅 과정을 경험했다.
