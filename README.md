_This project has been created as part of the 42 curriculum by syokota_
## Description

このプロジェクトは、仮想環境上に安全なサーバーを一から構築することを目的としたプロジェクトです。パソコンやサーバーが、裏側でどのように設定されているのかを、実際に手を動かして学ぶことが目標です。具体的には、以下のようなことを自分の手で行います。
- 仮想マシン(VM)を使って、パソコンの中にもう1台のサーバーを作る
- OS(Debian または Rocky Linux)を自分でインストールし、ディスクの区画(パーティション)を適切に分割する
- 誰でも管理者権限を使えてしまう状態を避けるため、ユーザーやグループの権限を適切に設定する
- 外部からの不正なアクセスを防ぐため、ファイアウォールやアクセス制御の仕組みを導入する
- パスワードの使い回しや簡単なパスワードを防ぐための強制的なルール(パスワードポリシー)を設定する
- サーバーの状態(CPU使用率やディスク容量など)を定期的に自動で記録する仕組みを作る
  
上記の項目を通して、ネットワーク上に安全なサーバー環境を構築し、システム管理の基礎(OSインストール、セキュリティ設定、ネットワーク設定など)を学ぶことを目的としています。

このプロジェクトでは、設定が理解しやすく初心者にも扱いやすいことから、**Debian**をサーバー用のLinuxディストリビューションとして採用しました。以下にDebianとRocky Linuxの比較を記載します。

---
### Debian vs Rocky Linux

DebianとRocky Linuxは、どちらもLinuxをベースにしたOSであるものの、開発の背景や想定している使い道が異なります。
Debianは1993年から続くディストリビューションで、特定の企業に属さず、コミュニティによって開発が続けられています。個人のサーバー構築や学習用途でよく使われており、無料で使える範囲が広いのが特徴です。
一方Rocky Linuxは、企業向けOSであるRed Hat Enterprise Linux(RHEL)と互換性を持つように作られたディストリビューションです。もともとCentOSというOSがこの役割を担っていましたが、開発方針の変更をきっかけに、その後継としてRocky Linuxが2021年に登場しました。企業の業務システムなど、RHELを前提にした環境で使われることが多いです。

| | Debian | Rocky Linux |
|---|---|---|
| 開発体制 | コミュニティ主導 | Rocky Enterprise Software Foundationが運営 |
| 主な用途 | 個人サーバー、学習、幅広い用途 | 企業システム、業務用サーバー |
| ソフトウェアの更新頻度 | 安定性重視のため、比較的古いバージョンで固定されやすい | Debianと同程度だが、企業向けの更新サイクルに合わせている |
| 商用ソフトとの相性 | 特に想定されていない | 良い(業務用ソフトはRHEL系を前提にしていることが多い) |

**メリット・デメリット**

- **Debian**
  - メリット:情報や解説記事がネット上に非常に多く、個人利用や学習用途で困ったときに調べやすい
  - デメリット:企業向けの有償サポートが用意されておらず、トラブル対応は自力で行う必要がある

- **Rocky Linux**
  - メリット:企業で広く使われているRHELとほぼ同じ動作をするため、実務に近い環境で学べる
  - デメリット:登場してからまだ数年しか経っておらず、Debianに比べると情報量が少ない
---

### AppArmor vs SELinux

AppArmorとSELinuxは、どちらもLinuxに搭載されている「アクセス制御」の仕組みです。通常のUNIX権限(読み取り・書き込み・実行の許可)だけでは、あるプログラムが乗っ取られたりバグを起こしたりした場合に、想定以上のファイルやプロセスへアクセスされてしまう可能性があります。これを防ぐために、プログラムごとに「アクセスできる範囲」をあらかじめ制限しておくのがこの仕組みの役割です。
AppArmorはDebianやUbuntuに標準搭載されており、ファイルパスを基準にルールを設定します。「このプログラムはこのディレクトリ配下のファイルにしかアクセスできない」といった形で指定しており、設定内容が人間にとって読みやすいのが特徴です。
SELinuxはRocky LinuxやRHELに標準搭載されており、ファイルやプロセスにラベルを付け、ラベル同士の組み合わせによってアクセス可否を判断する仕組みです。ファイルパスに依存しないため柔軟で強力な制御が可能ですが、その分設定の仕組み自体が複雑になっています。

| | AppArmor | SELinux |
|---|---|---|
| 標準搭載OS | Debian, Ubuntu | Rocky Linux, RHEL |
| ルールの決め方 | ファイルパス単位で許可・禁止を指定 | ラベル(セキュリティコンテキスト)同士の組み合わせで判断 |
| 設定の難易度 | 比較的低い | 高い |
| アクセス制御の細かさ | 一定の範囲まで | 非常に細かい |

**メリット・デメリット**

- **AppArmor**
  - メリット:設定がファイルパスベースで直感的に理解しやすい
  - デメリット:SELinuxと比較すると制御できる範囲が限定的

- **SELinux**
  - メリット:非常に細かい単位でアクセス制御ができ、セキュリティレベルが高い
  - デメリット:仕組みが複雑なため、意図しないアクセス拒否が発生した際の原因調査に時間がかかりやすい
---

### UFW vs firewalld

UFWとfirewalldは、どちらもサーバーへの通信を制御するファイアウォールの管理ツールです。外部からの通信のうち、許可したものだけを通し、それ以外は遮断するというルールを設定するために使います。
UFW(Uncomplicated FireWall)はDebianやUbuntuに標準搭載されており、シンプルさを重視して設計されています。「22番ポートを許可する」といった操作をコマンド1行で行える手軽さが特徴です。内部的にはiptablesという仕組みをより扱いやすくラップしたものになっています。
firewalldはRocky LinuxやRHELに標準搭載されており、通信ルールを「ゾーン」という単位でグループ化して管理します。自宅用・社内用・公開サーバー用など、状況ごとに異なるルールセットを切り替えられるため、より複雑なネットワーク構成に対応できます。

| | UFW | firewalld |
|---|---|---|
| 標準搭載OS | Debian, Ubuntu | Rocky Linux, RHEL |
| 設定方法 | ポート番号などを指定してコマンド1行で設定 | ゾーン単位でルールをグループ化して管理 |
| 設定変更の反映 | 場合によっては再起動が必要 | 再起動せずに即時反映される |
| 向いている構成 | 単一用途のシンプルなサーバー | 複数のネットワーク環境を使い分ける構成 |

**メリット・デメリット**

- **UFW**
  - メリット:コマンドが直感的で、すぐに設定を始められる
  - デメリット:用途ごとに細かくルールを使い分けたい場合には対応しにくい

- **firewalld**
  - メリット:ゾーンによって柔軟なルール管理ができ、複雑な構成にも対応できる
  - デメリット:「ゾーン」「サービス」といった概念を理解する必要があり、最初は扱いにくく感じやすい

---

### VirtualBox vs UTM

VirtualBoxとUTMは、どちらも1台のパソコンの中に別のパソコン環境(仮想マシン)を作り出すためのソフトです。これを使うことで、実機を用意しなくても、普段使っているWindowsやMacの中でDebianやRocky Linuxを動かし、自由に試したり作り直したりすることができます。
VirtualBoxはOracle社が開発しているソフトで、歴史が長く、WindowsやIntelチップ搭載のMacで広く使われてきました。情報量が多く、多くの環境で安定して動作しますが、Apple Silicon(M1以降のMac)については開発の対応が追いついていない部分があり、動作が不安定になることがあります。
UTMはQEMUというオープンソースの仮想化技術をベースにしたソフトで、Apple Siliconに最適化されています。M1以降のMacでも軽快に動作しますが、Windowsやその他のIntel系パソコンでは選択肢にならず、機能面でもVirtualBoxほど充実してはいません。

| | VirtualBox | UTM |
|---|---|---|
| 開発元 | Oracle社 | オープンソースコミュニティ(QEMUベース) |
| 対応環境 | Windows、Intel搭載Mac | Apple Silicon搭載Mac(M1/M2/M3など) |
| 情報量 | 歴史が長く豊富 | Mac向けに限定される |

**メリット・デメリット**

- **VirtualBox**
  - メリット:歴史が長く、Windows・Intel Macでの実績が豊富で情報も見つけやすい
  - デメリット:Apple Silicon搭載Macでは動作が不安定になる場合がある

- **UTM**
  - メリット:Apple Siliconに最適化されており、Mac上で軽快に動作する
  - デメリット:Windows/Intel系のパソコンでは使えず、機能面ではVirtualBoxよりシンプル

---

## Instructions

### 前提条件

- 仮想化ソフト:**VirtualBox**
- OSインストールメディア:**Debian** の公式ISOイメージ
- 割り当てリソースの目安:CPU [1]コア、メモリ [2048]MB、ディスク [32]GB

### 1. 仮想マシンの作成

1. VirtualBoxを起動し、新規仮想マシンを作成する
2. OSの種類として Debianを選択する
3. メモリ・CPU・ディスク容量を上記の前提条件に沿って設定する
4. ダウンロードした ISO イメージを仮想マシンに割り当てる

### 2. OSのインストール

1. 言語・キーボード・タイムゾーンを設定する
2. ホスト名を `[任意のホスト名]` に設定する
3. パーティション分割は「手動(Manual)」を選択し、以下の構成にする

   | マウントポイント | 割り当て容量 |
   |---|---|
   | `/` | [10]GB |
   | `/swap` | [2.3]GB |
   | `/home` | [5]GB |
   | `/var` | [3]GB |
   | `/srv` | [3]GB |
   | `/tmp` | [3]GB |
   | `/var/log` | [4]GB |

5. rootユーザーとは別に、一般ユーザー `[ユーザー名]` を作成する
6. 最小構成でインストールを行い、不要なパッケージ(デスクトップ環境など)は導入しない

### 3. 初期設定・セキュリティ設定

インストール後、以下の設定を順番に行う。

1. パスワードポリシーの設定([libpam-pwquality] を使用し、有効期限・複雑さ要件などを設定)
2. sudo の設定(試行回数制限、ログ記録などを `/etc/sudoers` に記載)
3. ファイアウォールの設定(**UFW** を使用し、必要なポートのみ許可)
4. セキュリティ機構の有効化(**AppArmor** が有効になっていることを確認)
5. SSHの設定(デフォルトポート [4242] に変更、root ログインを禁止)

### 4. 動作確認(ピアレビューの進行手順)

Born2beRootのピアレビューをスムーズに進行するための操作手順は以下の通りです。

#### 1. 事前準備(ハッシュの確認とスナップショット)

評価開始時、VMを起動する前に、提出した `signature.txt` と現在の仮想ディスクのハッシュ値が一致するかを確認します。

```bash
#ハッシュ値を計算するコマンド
sha1sum ~/sgoinfre/born2beroot/[VM名].vdi

#diffを使って、計算されたハッシュ値を比較するコマンド
diff signature.txt <(shasum ~/VirtualBox\ VMs/あなたのVM名/あなたのVM名.vdi | awk '{print $1}')

```

#### 2. 基本情報とOSの確認

```bash
# OSバージョン、アーキテクチャ、カーネルの確認
hostnamectl

# ディスクのパーティションとLVMの確認
lsblk

# AppArmorの動作確認
sudo aa-status
```

#### 3. ユーザーとグループの確認

```bash
# 現在のユーザーが所属しているグループの確認
groups

# 新規ユーザーの作成とパスワードポリシーの証明
sudo adduser newuser
# 簡単なパスワードを入れて弾かれることを確認する

# 作成したユーザーをグループに追加
sudo usermod -aG evaluatinggroup newuser
getent group evaluatinggroup
```

#### 4. UFW(ファイアウォール)とSSHの確認

```bash
# UFWのステータス確認
sudo ufw status

# ホストOSからのSSH接続テスト
ssh newuser@127.0.0.1 -p 4242
```

#### 5. パスワードポリシーの確認

```bash
# パスワードの有効期限ルールの確認
sudo cat /etc/login.defs | grep PASS

# パスワードの複雑さルールの確認
sudo cat /etc/security/pwquality.conf

# ユーザーへのポリシー適用確認
sudo chage -l root
```

#### 6. sudoの設定とログの確認

```bash
# sudoのルール設定の確認
sudo cat /etc/sudoers

# sudoの失敗テストとログの確認
su - newuser
sudo ls   # わざと間違ったパスワードを3回入力する
exit

# ログファイルの中身を確認
sudo cat /var/log/sudo/00/00/01/log
```

#### 7. monitoring.sh と cron

```bash
# スクリプトの動作確認
sudo /usr/local/bin/monitoring.sh

# cronの設定確認とスケジュール変更
sudo crontab -l
sudo crontab -e
# */10 を * に変更して保存し、wallメッセージが表示されるか確認する

# スクリプトの定期実行を停止する
sudo systemctl stop cron
```

#### 8. ホスト名の変更

```bash
sudo hostnamectl set-hostname new-hostname
sudo nano /etc/hosts   # 127.0.1.1 のホスト名も書き換える
sudo reboot
```

### 9. ボーナスパートの検証(Bonus Part)

#### 9.1. 追加パーティションの確認

```bash
lsblk
```

> 必須パートの要件に加え、`/var`, `/srv`, `/tmp`, `/var/log` などの論理ボリューム(LVM)が正しく分割・マウントされていることを示します。

#### 9.2. WordPress環境の確認(lighttpd, MariaDB, PHP)

**通信の流れ**

ホストOS(自分のパソコン)のブラウザから見えているWordPressのサイトは、以下のような経路でVM内の各サービスが連携して表示されています。

```
ブラウザ(ホストOS)
   ↓ http://localhost:8080 へアクセス
VirtualBoxのポートフォワーディング(ホスト8080 → ゲスト80)
   ↓
lighttpd(Webサーバー。リクエストを受け取る)
   ↓ PHPファイルの処理を依頼
php-fpm(PHPの実行エンジン)
   ↓ 記事データ・ユーザー情報などを取得
MariaDB(データベース。WordPressの中身を保存)
   ↓
処理結果がlighttpd経由でブラウザに返され、ページが表示される
```

つまり、lighttpdが「受付」、php-fpmが「処理担当」、MariaDBが「データの保管庫」という役割分担になっており、この3つのサービスがすべて正常に動いていないと、WordPressのページは正しく表示されません。次のポート確認・サービス確認は、この経路のどこが動いているかを1つずつ確かめる作業になります。

ポートの開放確認:

```bash
sudo ufw status
```

> HTTP通信用として `80/tcp`がALLOWになっていることを示します。これはブラウザからのリクエストがUFWを通過できることを確認する手順です。

サービスの稼働状況の確認:

```bash
sudo systemctl status lighttpd
sudo systemctl status mariadb
sudo systemctl status php*-fpm
```

> 全てのサービスが `active (running)` になっていることを示します。上記の経路図の「受付」「処理担当」「保管庫」がすべて動いている状態です。

ブラウザからのアクセス確認:

ホストOS(自分のパソコン)のWebブラウザを開き、以下のURLにアクセスします。

- ポートフォワーディングの場合:`http://localhost:8080`(設定したホスト側のポート)

> WordPressのサイトが正常に表示されることを証明します。ここで表示が正しく行われるということは、上記の経路がすべて正常に機能していることの証明になります。

#### 9.3. 追加サービス(Fail2ban)の確認

**Fail2banとは**

SSHへのログイン試行を監視し、一定回数以上パスワードを間違えたIPアドレスを、一定時間だけ自動的に接続禁止にする仕組みです。総当たり攻撃(ブルートフォース攻撃)への対策として動作します。

サービスの稼働状況の確認:

```bash
sudo systemctl status fail2ban
```

監視状態(Jail)の確認:

```bash
sudo fail2ban-client status sshd
```

> SSHポートに対する監視が有効になっており、現在のブロック(Ban)リストなどが表示されることを説明します。これにより、無差別なSSH攻撃からサーバーを自動的に守る仕組みが機能しています。

**一連の動作を実演する手順**

実際にBanされる様子を見せることで、Fail2banが機能していることを証明できます。

1. 別のターミナルから、わざと間違ったパスワードでSSH接続を、設定した上限回数分(例:3回)失敗させる

```bash
   ssh newuser@127.0.0.1 -p 4242
   # パスワードを間違えて入力する(上限回数分繰り返す)
```

2. 上限回数を超えると接続自体が拒否されるようになる(以下のようなエラーが出る)

```bash
   ssh newuser@127.0.0.1 -p 4242
   # ssh: connect to host 127.0.0.1 port 4242: Connection refused
```

3. Banされたことを確認する

```bash
   sudo fail2ban-client status sshd
```

   `Banned IP list` に、接続を試みたIPアドレス(`127.0.0.1`など)が表示されていれば、Banが成功している。

4. Banを解除(unban)する

```bash
   sudo fail2ban-client set sshd unbanip 127.0.0.1
```

5. 解除されたことを確認する

```bash
   sudo fail2ban-client status sshd
```

   `Banned IP list` から該当IPが消えていれば、解除が完了している。

6. 解除後、再度SSH接続できることを確認する

```bash
   ssh newuser@127.0.0.1 -p 4242
```

## Resources

本プロジェクトの概念理解および構築において、以下の公式ドキュメントやリソースを参考にしました。

### 仮想化とOS(Virtualization & OS)

- **Debian Administrator's Handbook**:https://debian-handbook.info/
  Debianの基本思想やパッケージ管理(`apt`)の仕組みを理解するために参照しました。

- **ArchWiki - LVM**:https://wiki.archlinux.jp/index.php/LVM
  LVM(論理ボリュームマネージャー)の概念と、物理ボリューム・論理ボリュームの構造を学ぶために非常に役立ちました。

### セキュリティとシステム管理(Security & System Admin)

- **UFW Essentials(Ubuntu Community Help Wiki)**:https://help.ubuntu.com/community/UFW
  UFWの基本的なポート開放とデフォルトルールの設定について参照しました。

- **Sudo Manual(`man sudoers`)**:https://www.sudo.ws/docs/man/sudoers.man/
  `requiretty` や `passwd_tries` など、sudoの厳格なポリシー設定のために公式マニュアルを確認しました。

- **Crontab Guru**:https://crontab.guru/
  `monitoring.sh` を10分ごとに実行するためのcronスケジュールの構文(`*/10 * * * *`)を視覚的に検証するために使用しました。

### ボーナスパート(Bonus Part)

- **DigitalOcean - How To Install LEMP Stack**:https://www.digitalocean.com/community/tutorials/how-to-install-linux-nginx-mariadb-php-lemp-stack-on-debian-11
  (※NginxはLighttpdに読み替えて活用)MariaDBとPHP(php-fpm)の連携設定の基礎として参照しました。

- **Fail2ban Official Wiki**:https://www.fail2ban.org/wiki/index.php/Manual

### AIツールの利用について(Usage of AI Tools)

本プロジェクトでは、42の学習ガイドライン(AI Instructions)に基づき、AIを「コードや答えを直接出力させるツール」としてではなく、「概念を深く理解するためのパーソナルチューター」として活用しました。

**活用したタスク:**

1. MAC(強制アクセス制御)におけるAppArmorとSELinuxの仕組みの違いや、なぜ従来のDACだけでは不十分なのかという概念の理解
2. LVMの階層構造や、パーティション暗号化(`crypt`)がどのレイヤーで機能しているかの図解的理解
3. ピアレビュー時に想定される質問(例:「`apt` と `aptitude` の違いは?」)に対する、自分の理解度チェックと壁打ち相手として

**プロジェクトのどの部分か:**

必須パートの技術選定理由の言語化、および `monitoring.sh` で使用する `awk` や `grep` などのコマンドの振る舞いの理解に使用しました。直接的な設定ファイルのコピペは一切行わず、すべて自己の理解に基づき構築しています。
