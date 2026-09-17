# Linux User & Permission Practice

## 1. 실습 목적

Linux 환경에서 사용자 및 파일 권한의 기본 개념을 이해하고,
chmod, chown, chgrp 명령어를 이용하여 파일과 디렉터리의
소유자 및 접근 권한을 변경하는 방법을 실습한다.

또한 다른 사용자(testuser)를 생성하여 실제 파일 접근을 테스트하고,
권한 설정에 따라 접근 가능 여부가 어떻게 달라지는지 확인한다.

---

## 2. 실습 환경

- OS: Ubuntu on WSL2
- Shell: Bash
- Host OS: Windows
- Main User: stave123
- Test User: testuser
- Repository: linux-server-lab

---

## 3. Linux 파일 권한 구조

Linux에서 ls -l 명령어를 사용하면 파일의 권한과
소유자, 그룹 정보를 확인할 수 있다.

예시:

-rwxr-xr-x 1 stave123 stave123 permission-test.txt

권한 부분은 다음과 같이 세 영역으로 나뉜다.

-rwx r-x r-x
 │    │   │
 │    │   └── 기타 사용자(Other)
 │    └────── 그룹(Group)
 └─────────── 소유자(Owner)

각 권한은 다음과 같은 의미를 가진다.

- r : Read - 읽기
- w : Write - 쓰기
- x : Execute - 실행

---

## 4. chmod 실습

### 4.1 chmod 개념

chmod는 파일이나 디렉터리의 접근 권한을 변경하는 명령어이다.

권한을 숫자로 표현할 경우 다음과 같이 계산한다.

r = 4
w = 2
x = 1

따라서:

7 = 4 + 2 + 1 = rwx
6 = 4 + 2     = rw-
5 = 4 + 1     = r-x
4 = 4         = r--
0 = 권한 없음

### 4.2 주요 권한 예시

600 → rw-------
644 → rw-r--r--
755 → rwxr-xr-x
777 → rwxrwxrwx

777은 소유자, 그룹, 기타 사용자 모두에게
읽기/쓰기/실행 권한을 부여한다.

실제 서버 환경에서는 불필요하게 광범위한 권한을 부여할 수 있으므로
보안상 주의가 필요하다.

---

## 5. chown 실습

chown은 파일이나 디렉터리의 소유자를 변경하는 명령어이다.

실습에서는 testuser 계정을 생성한 후
파일의 소유자를 변경하는 작업을 수행하였다.

sudo chown testuser permission-test.txt

변경 후 ls -l을 통해 소유자가 testuser로 변경되는 것을 확인하였다.

또한 다음과 같이 사용자와 그룹을 동시에 지정할 수 있다.

sudo chown testuser:testuser permission-test.txt

이 경우:

소유자 → testuser
그룹   → testuser

로 설정된다.

---

## 6. chgrp 실습

chgrp는 파일이나 디렉터리의 그룹을 변경하는 명령어이다.

chgrp 그룹이름 파일이름

chown과 비교하면 다음과 같다.

chown → 소유자 변경
chgrp → 그룹 변경

실습을 통해 파일의 소유자와 그룹을 각각 변경할 수 있음을 확인하였다.

---

## 7. 파일 권한과 디렉터리 권한의 차이

파일과 디렉터리에서 r, w, x의 의미에는 차이가 있다.

### 파일

r → 파일 내용 읽기
w → 파일 내용 수정
x → 파일 실행

### 디렉터리

r → 디렉터리 내부 목록 확인
w → 파일 및 디렉터리 생성/삭제
x → 디렉터리를 통과하여 내부에 접근

특히 디렉터리의 x 권한은 하위 파일에 접근할 때 중요하다.

---

## 8. 사용자 접근 권한 테스트

실제 권한이 어떻게 적용되는지 확인하기 위해
testuser라는 테스트 계정을 생성하였다.

먼저 실습용 파일을 생성하였다.

touch secret.txt

파일의 소유자는 stave123으로 설정하였다.

이후 다음과 같이 권한을 설정하였다.

chmod 600 secret.txt

확인 결과:

-rw------- 1 stave123 stave123 secret.txt

이 상태에서 testuser로 사용자 전환 후 파일을 읽어보았다.

cat /home/stave123/linux-permission-practice/secret.txt

결과:

Permission denied

이는 testuser가 파일의 소유자가 아니며,
그룹 및 기타 사용자에게 읽기 권한이 없기 때문이다.

---

## 9. chmod 644 테스트

이후 파일 권한을 다음과 같이 변경하였다.

chmod 644 secret.txt

결과:

-rw-r--r-- 1 stave123 stave123 secret.txt

이 상태에서는 파일 자체의 권한만 보면
testuser도 r-- 권한을 가지고 있으므로
파일을 읽을 수 있어야 한다.

그러나 실제 접근 결과는 다음과 같았다.

cat: /home/stave123/linux-permission-practice/secret.txt: Permission denied

이를 통해 파일 자체의 권한만으로 접근 가능 여부가 결정되지 않는다는 것을 확인하였다.

---

## 10. namei를 이용한 권한 문제 분석

파일 접근 경로를 확인하기 위해 namei -l 명령어를 사용하였다.

namei -l /home/stave123/linux-permission-practice/secret.txt

확인 결과:

drwxr-xr-x root     root     /
drwxr-xr-x root     root     home
drwxr-x--- stave123 stave123 stave123
drwxr-xr-x stave123 stave123 linux-permission-practice
-rw-r--r-- stave123 stave123 secret.txt

secret.txt 자체에는 644 권한이 설정되어 있었지만,
상위 디렉터리인 /home/stave123의 기타 사용자 권한이 다음과 같았다.

---

따라서 testuser는 /home/stave123 디렉터리를 통과할 수 없었다.

---

## 11. 디렉터리 x 권한의 중요성

디렉터리에서 x 권한은 해당 디렉터리를 통과하여
하위 파일이나 디렉터리에 접근할 수 있는 권한이다.

따라서 다음과 같은 경로에 접근하려면:

/home/stave123/linux-permission-practice/secret.txt

각 상위 디렉터리를 통과할 수 있어야 하며,
마지막 파일에는 필요한 파일 권한이 있어야 한다.

접근 경로:

/home
  ↓
/home/stave123
  ↓
linux-permission-practice
  ↓
secret.txt

이 실습을 통해 파일의 권한뿐만 아니라
파일이 위치한 디렉터리의 접근 권한도
함께 확인해야 한다는 것을 확인하였다.

---

## 12. 절대경로와 상대경로

Linux에서 경로는 절대경로와 상대경로로 구분할 수 있다.

### 절대경로

/에서 시작하는 전체 경로이다.

예:

chmod 755 /home/stave123/linux-permission-practice/secret.txt

현재 작업 디렉터리와 관계없이 항상 동일한 파일을 지정할 수 있다.

### 상대경로

현재 작업 디렉터리를 기준으로 파일이나 디렉터리를 지정한다.

예를 들어 현재 위치가:

/home/stave123/linux-permission-practice

인 경우:

chmod 755 secret.txt

은 다음 파일을 의미한다.

/home/stave123/linux-permission-practice/secret.txt

또한 현재 위치가 /home/stave123이라면:

chmod 755 linux-permission-practice/secret.txt

와 같이 여러 단계의 상대경로를 사용할 수도 있다.

---

## 13. 실습을 통해 확인한 내용

1. chmod를 이용하여 파일 및 디렉터리의 권한을 변경할 수 있다.
2. Linux 권한은 소유자, 그룹, 기타 사용자로 구분된다.
3. chown을 이용하여 파일의 소유자를 변경할 수 있다.
4. chgrp를 이용하여 파일의 그룹을 변경할 수 있다.
5. 파일 권한과 디렉터리 권한은 동일한 rwx 구조를 사용하지만 의미가 다르다.
6. 디렉터리의 x 권한은 하위 파일에 접근하기 위해 중요하다.
7. 파일 자체의 권한이 충분하더라도 상위 디렉터리의 접근 권한이 부족하면 파일에 접근할 수 없다.
8. namei -l을 이용하면 파일 경로를 구성하는 각 단계의 권한을 확인할 수 있다.
9. 절대경로는 /부터 전체 경로를 지정하며, 상대경로는 현재 작업 디렉터리를 기준으로 경로를 지정한다.

---

## 14. 실습 결과

이번 실습을 통해 Linux의 파일 권한을 단순히 숫자로 설정하는 것뿐만 아니라,
실제 사용자 간 접근 제어에 어떻게 적용되는지 확인하였다.

특히 secret.txt의 권한을 644로 변경했음에도
testuser가 파일을 읽지 못하는 문제를 namei -l을 이용하여 분석하였다.

이를 통해 Linux의 권한 관리는 개별 파일의 권한뿐만 아니라
파일이 위치한 디렉터리의 접근 권한까지 함께 고려해야 한다는 것을 확인하였다.
