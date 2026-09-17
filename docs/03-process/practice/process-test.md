# Process Practice

## 1. 프로세스 확인

```bash
ps
ps aux
```

`ps`와 `ps aux`를 사용하여 실행 중인 프로세스를 확인했다.

---

## 2. 백그라운드 프로세스

```bash
sleep 300 &
jobs
fg %1
```

백그라운드에서 프로세스를 실행하고 `jobs`와 `fg`를 이용해 상태를 확인했다.

---

## 3. 프로세스 종료

```bash
sleep 300 &
kill PID
```

PID를 확인한 후 `kill` 명령어를 이용하여 프로세스를 종료했다.

---

## 4. CPU 사용량 확인

```bash
yes > /dev/null &
top
pkill yes
```

`yes` 프로세스를 이용하여 CPU 사용량 변화를 확인하고 `top`에서 높은 CPU 사용량을 확인했다.

---

## 5. 서비스 관리

```bash
systemctl status cron
sudo systemctl stop cron
sudo systemctl start cron
```

`cron` 서비스를 직접 중지하고 다시 시작하면서 서비스 상태 변화를 확인했다.

---

## 6. 프로세스 관계 확인

```bash
ps -ef | grep '[c]ron'
pstree -p 1
```

`cron` 서비스가 실제 프로세스로 실행되는 것을 확인하고 `pstree`를 통해 프로세스 관계를 확인했다.
