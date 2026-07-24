_This project has been created as part of the 42 curriculum by syokota_

## 1. Description
Born2beRootは、仮想化技術を使って、Linux サーバー環境をゼロから設計・構築するプロジェクトです。
本プロジェクトの目的は、システム管理の基礎、堅牢なセキュリティポリシー（パスワード要件、権限管理、ファイアウォール）、ストレージ管理およびサーバーサービスの運用に対する実践的な理解を深める。

| 項目 | 設定内容 |
| :--- | :--- |
| **Operating System** | Debian 12 (Bookworm) - Minimal Install |
| **Virtualization** | VirtualBox |
| **Storage & Security** | LUKS Encrypted + LVM (Multi-partition setup) |
| **Mandatory Services** | SSH (Port 4242), UFW, Sudo (with strict logging) |
| **Bonus Services** | Web Server (`Lighttpd` + `MariaDB` + `PHP-FPM`), WordPress, `Fail2ban` |

---

### 1.2 Choice of Operating System
本プロジェクトでは **Debian 12 (Bookworm)** を選択しました。

#### Debian vs Rocky Linux の比較と選択理由

| OS | メリット (Advantages) | デメリット (Disadvantages) |
| :--- | :--- | :--- |
| **Debian** | • 安定性が極めて高く、バグが少ない<br>• `.deb` パッケージと `apt` コマンドが直感的に使いやすい<br>• 軽量で、リソース制限のある仮想マシンに最適<br>• コミュニティが巨大でトラブルシューティングが容易 | • 最新のソフトウェエリリースの導入が遅い（安定性重視のため）<br>• エンタープライズ向け商用サポートの枠組みではない |
| **Rocky Linux** | • RHEL (Red Hat Enterprise Linux) と 100% 互換の企業標準<br>• 10年間の長期サポート (LTS) でエンタープライズ向き<br>• 強力なセキュリティ（SELinux が標準装備） | • 初心者には設定やパッケージ管理（`dnf`/`rpm`）が少し複雑<br>• Debian に比べて初期状態でのシステムリソース消費がやや大きい |

**【選択理由】**
サーバー構築およびLinuxシステム管理の基礎を学ぶ上で、**「軽量さ」「圧倒的な安定性」「パッケージ管理の透明性」** を最優先に考慮し、Debian を選択しました。特に仮想マシン（2vCPU / 2GB RAM）上での LLMP スタック（Lighttpd/WordPress）の高速動作において、Debian の軽量さが大きな優位性を発揮します。

---

### 1.3 Main Design Choices
プロジェクトの構築にあたり、セキュリティと可用性を両立させるために以下の主要な設計選択を行いました。

* **パーティション設計 (LVM & LUKS):**
  Phase 1 の段階でディスク全体を LUKS で暗号化し、LVM を用いて論理ボリュームを分離（`/`, `/boot`, `swap`, `/home`, `/var`, `/srv`, `/tmp`, `/var/log`）する堅牢な構成を採用しました。これにより、ログファイル（`/var/log`）の肥大化や一時ファイルの暴走がシステムルートを圧迫して OS がクラッシュする事態を防ぎます。
* **セキュリティ・ユーザーポリシー:**
  * **パスワード:** 有効期限（最大30日/最短2日）、最小10文字以上、大文字・小文字・数字の必須化を `login.defs` と `pwquality.conf` で強制。
  * **権限管理:** `root` での直接アクセスおよび SSH ログインを完全禁止（`PermitRootLogin no`）。一般ユーザーのみを作成し、特権操作は `sudo` のみで実行させ、かつすべての実行履歴を `/var/log/sudo/` に記録して監査トレイルを確保。
* **導入サービス (Bonus):**
  Webサーバーには Apache/Nginx よりも省リソース・高速な **Lighttpd** を採用しました。また、SSHの公開ポート（4242）に対するパスワード総当たり攻撃を動的に防ぐため、不正アクセス自動遮断システムである **Fail2ban** を導入しています。

---

### 1.4 Technical Comparisons
インフラ構築技術のコアとなる 3 つのテーマについて、主要ツールの比較を行いました。

#### 1. AppArmor vs SELinux (強制アクセス制御: MAC)
* **AppArmor (Debian標準):** **「パスベース (Path-based)」** のセキュリティモデルです。各プログラムやファイルが「どのファイルパスにアクセスしてよいか」をプロファイルで制御します。設定やデバッグがシンプルで、システムへのオーバーヘッドが少ないのが特徴です。
* **SELinux (Rocky/RHEL標準):** **「ラベルベース (Label-based)」** のセキュリティモデルです。すべてのファイルやプロセスにセキュリティラベルを付与し、極めて厳格な制御を行います。セキュリティは最高レベルですが、設定が非常に複雑です。

#### 2. UFW vs firewalld (ファイアウォール管理ツール)
どちらも Linux カーネルのパケットフィルタ（`iptables` / `nftables`）の操作を簡単にするフロントエンドツールです。
* **UFW (Uncomplicated Firewall):** 「ルールベース」で管理します。`sudo ufw allow 4242/tcp` のように直感的なコマンドでポートを開閉でき、シンプルでエラーが起きにくいのがメリットです。
* **firewalld:** 「ゾーンベース (Zone-based)」で管理します。「パブリック」「社内ネットワーク」など、接続先の信頼度に応じたゾーンを作ってルールを切り替えるため、複雑なネットワーク環境やエンタープライズに適しています。

#### 3. VirtualBox vs UTM (仮想化プラットフォーム)
* **VirtualBox:** Type 2（ホスト型）仮想化ソフトウェアです。オープンソースでクロスプラットフォーム対応しており、x86_64 アーキテクチャの完全な仮想化が得意です。設定の再現性が高く、サーバー構築の学習において最も普及しています。
* **UTM:** Apple Silicon (M1/M2/M3) Mac に最適化された仮想化/エミュレーションソフトウェアです。QEMU と Apple の Hypervisor.framework を利用しており、ARM ベースの Mac 上で x86_64 のエミュレーションや、超高速な ARM 仮想マシンの実行を可能にします。

---

## 2. Instructions

### 2.1 Virtual Machine Execution & Access
本プロジェクトの仮想マシン（VM）は **VirtualBox** で稼働します。通信は以下のポートフォワーディング設定を通じて行われます。

* **SSH 接続:** ホストのポート `4242` $\rightarrow$ ゲストのポート `4242`
* **Web/WordPress 接続:** ホストのポート `8080` $\rightarrow$ ゲストのポート `80`

**【起動とアクセス手順】**
1. VirtualBox 上で仮想マシンを起動し、LUKS のパスフレーズを入力して OS をロードします。
2. ホストPCのターミナルから SSH で接続します：
   ```bash
   ssh <username>@127.0.0.1 -p 4242