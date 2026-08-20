# FPilot 日本語表示パッチ (fpilot-ja)

FPilot v0.8.3 用の日本語表示パッチスクリプトです。Windows のドラッグ&ドロップだけで、公式配布の `FPilot.exe` から日本語グリフ対応版 `FPilot_JA.exe` を生成できます。

> [!WARNING]
> このリポジトリ / Release には **FPilot 本体の EXE は含まれていません**。
>
> - 配布しているのはパッチスクリプト `FPilot_JA_patch.bat` のみです。
> - ユーザー自身が公式サイトから正規に入手した `FPilot.exe` を、**自分の PC 上で** BAT にドラッグ&ドロップして処理します。EXE の受け渡しや再配布は一切行いません。
> - FPilot / Voidstar の著作権その他一切の権利は原作者に帰属します。許可なく再配布しないでください。

## 最短手順

1. 公式サイトから正規の FPilot v0.8.3 を入手: <https://filepilot.tech/download>
2. パッチ BAT をダウンロード: [FPilot_JA_patch.bat](https://github.com/yuyu1815/fpilot-ja/releases/download/v0.8.3/FPilot_JA_patch.bat) — [Release ページ](https://github.com/yuyu1815/fpilot-ja/releases/tag/v0.8.3)
3. `FPilot.exe` を `FPilot_JA_patch.bat` にドラッグ&ドロップ
4. フォント設定を行う (「[4. フォント設定(日本語表示に必要)](#4-フォント設定日本語表示に必要)」)
5. 生成された `FPilot_JA.exe` を起動

初めての方は、下の「使用方法」を上から順にお読みください。

## 使用方法

### 1. 公式版を入手

まず公式サイトから正規の FPilot v0.8.3 を入手します。

**公式ダウンロード: <https://filepilot.tech/download>**

入手した `FPilot.exe` が本パッチの対象バージョン (v0.8.3) であることを確認してください。

### 2. パッチBATを入手

以下のいずれかの方法で `FPilot_JA_patch.bat` を入手します。

- BAT 直接ダウンロード: [FPilot_JA_patch.bat](https://github.com/yuyu1815/fpilot-ja/releases/download/v0.8.3/FPilot_JA_patch.bat)
- Release ページ: <https://github.com/yuyu1815/fpilot-ja/releases/tag/v0.8.3>
- Code ボタンからリポジトリ全体を取得しても構いません

#### 対応表

| 対応FPilotバージョン | パッチBAT | Release | 生成ファイル | 状態 |
|---|---|---|---|---|
| v0.8.3 | `FPilot_JA_patch.bat` | [v0.8.3](https://github.com/yuyu1815/fpilot-ja/releases/tag/v0.8.3) | `FPilot_JA.exe` | ✅ 最新 |

> [!WARNING]
> - **BAT は対応バージョン専用です。異なるバージョンの EXE には使用しないでください。**
> - 対応していない EXE を渡した場合、署名検証により安全に中止します。
> - 今後の FPilot バージョンは、この表に対応 BAT と Release を追加します。
> - 同じフォルダに複数の `FPilot.exe` がある場合、表のバージョンと一致するものを選んでください。

> [!NOTE]
> Release に添付されているのは `FPilot_JA_patch.bat` のみです (**EXE 本体は添付していません**)。BAT ファイル単体で自己完結しており、Python など追加ツールのインストールは不要です (必要環境は Windows 標準の PowerShell のみ)。

### 3. BATへFPilot.exeをドラッグ&ドロップ

1. 正規に入手した `FPilot.exe` (v0.8.3) を `FPilot_JA_patch.bat` の上にドラッグ&ドロップします。
2. 数秒で `FPilot.exe` と同じフォルダに `FPilot_JA.exe` が生成されます。
3. 既に `FPilot_JA.exe` が存在する場合は、タイムスタンプ付きの `.bak-YYYYMMDD-HHMMSS` ファイルに自動バックアップされてから上書きされます。

生成物と元ファイルの違い:

| ファイル | 役割 | 変更の有無 |
|---|---|---|
| `FPilot.exe` | 元の公式 EXE | **一切変更されません** (読み取り専用でオープン) |
| `FPilot_JA.exe` | パッチ適用済みのコピー | 新規生成される日本語グリフ対応版 |
| `FPilot_JA.exe.bak-YYYYMMDD-HHMMSS` | 旧 `FPilot_JA.exe` のバックアップ | 上書き時に自動生成 |

コマンドラインから実行する場合:

```bat
FPilot_JA_patch.bat "C:\path\to\FPilot.exe"
```

引数に指定した `FPilot.exe` が処理され、同じディレクトリに `FPilot_JA.exe` が出力されます。

### 4. フォント設定(日本語表示に必要)

このパッチはフォントをハードコードしません。グリフの範囲テーブルのみを変更するため、**フォントはユーザーの `FPilot-Config.json` の設定がそのまま使用されます**。日本語を表示するには、ここでフォントの設定を行ってください。

設定ファイルの場所:

```
%APPDATA%\Voidstar\FilePilot\FPilot-Config.json
```

開き方:

1. `Win + R` を押して「ファイル名を指定して実行」を開く
2. `%APPDATA%\Voidstar\FilePilot` と入力
3. `Enter` を押す
4. 表示されたフォルダ内の `FPilot-Config.json` をメモ帳で開く

変更例 (`FontName` / `InspectorFontName` を書き換える):

```json
{
  "FontName": "malgun.ttf",
  "InspectorFontName": "malgun.ttf"
}
```

> [!IMPORTANT]
> FPilot v0.8.3 の `FontName` / `InspectorFontName` には、フォントのフェイス名 (`Yu Gothic UI` など) をそのまま指定するのではなく、**FPilot が受理する、Windows に登録されたフォントのファイル名 (拡張子 `.ttf`)** を指定してください。フェイス名をそのまま書いても受理されない場合があります。

- 実証済みの設定値:
  - `malgun.ttf` (Yu Mincho / 游明朝) — この環境で受理され、日本語表示が正常であることを実証済み
  - `yumindb.ttf` (Yu Mincho Demibold / 游明朝 Demibold) — 同じ Yu Mincho ファミリの別ウェイト
- `Yu Gothic UI`、`メイリオ`、`Noto Sans JP` などの**フェイス名をそのまま指定するのは避けてください**。受理されない可能性があります。
- フォントの実体が `.ttc` (TrueType Collection) の場合、このバージョンでは受理されない可能性があります。お使いの Windows 環境で実際に受理されるか確認してください。
- Explorer 標準の Yu Gothic UI は通常 TTF ではなく TTC のため、設定だけでは直接使えない可能性があります。
- 指定するファイル名は `C:\Windows\Fonts` に実在し、レジストリ (HKLM Fonts) に登録されているものです。

> [!TIP]
> 設定ファイルが見つからない場合は、**一度 FPilot を起動して終了した後**に、もう一度 `%APPDATA%\Voidstar\FilePilot` を確認してください。初回起動時に設定ファイルが生成されます。

### 5. FPilot_JA.exeを起動

生成された `FPilot_JA.exe` を起動すると、日本語グリフ対応版として動作します。元の `FPilot.exe` は変更されていないため、そのまま使い続けることもできます。

## 安全性

- **元の `FPilot.exe` は一切変更されません**（読み取り専用でオープンし、書き込みは行いません）。
- パッチは `FPilot.exe` のコピーに対してのみ適用されます。
- パッチ適用後、ファイル全体の差分がパッチ対象の 40 バイト以内に収まっていることを検証します。検証に失敗した場合は出力を削除して中断します。
- 途中で失敗した場合、不完全な `FPilot_JA.exe` は残しません。
- 必要環境は Windows PowerShell のみ（Windows 標準搭載）。Python 等のインストールは不要です。BAT ファイル単体で自己完結しています。

## 対応範囲

パッチは FPilot のグリフ範囲テーブル (idx6〜idx10) を以下の通り変更します。

| スロット | 範囲 | 内容 |
|---|---|---|
| idx6 | U+3000-U+33FF | かな・CJK句読点・enclosed CJK |
| idx7 | U+4E00-U+6DFB | 漢字パートA |
| idx8 | U+6DFC-U+8DF7 | 漢字パートB |
| idx9 | U+8DF8-U+9FFF | 漢字パートC |
| idx10 | U+FF00-U+FFEF | 全角英数・半角カナ |

漢字 (U+4E00-U+9FFF) を 3 つのスロットに分割しているのは、GPU グリフアトラス (D3D11 Texture2DArray) の上限対策です。1 つのスロットに漢字全体を入れるとスライス数が 2048 を超え、テクスチャ生成に失敗して漢字が一切表示されなくなるため、分割することで全てのスロットを上限内に収めています。

## 非対応の文字

- 絵文字 (U+1F300 など)
- CJK拡張B以降 (U+20000 以降)
- 異体字セレクタ (U+FE00-FE0F, U+E0100 以降)
- 上記対応範囲外の文字

これらは範囲テーブルの対象外のため、正しく表示されない場合があります。

## トラブルシューティング

| 症状 | 対処 |
|---|---|
| 日本語が表示されない / 文字化けする | 「[4. フォント設定(日本語表示に必要)](#4-フォント設定日本語表示に必要)」を見直す。特にフェイス名ではなく `.ttf` ファイル名を指定しているか、`.ttc` を指定していないかを確認 |
| `FPilot-Config.json` が見つからない | 一度 FPilot を起動して終了した後に、`%APPDATA%\Voidstar\FilePilot` を再確認 |
| BAT が「署名が一致しない」等で中断する | 対象が FPilot v0.8.3 か確認。異なるバージョンの EXE には安全に中断する設計です |
| `FPilot_JA.exe` が生成されない | BAT のログ出力 (SHA256 ハッシュなど) を確認の上、問題報告の項を参照 |

## 免責・権利表記

- FPilot / Voidstar の著作権その他一切の権利は原作者に帰属します。本リポジトリは日本語表示のための非公式パッチ スクリプトのみを提供するものであり、FPilot 本体の再配布は行いません。
- パッチの使用は自己責任でお願いします。

## 問題報告

不具合報告の際は、以下の情報を併記してください:

- 元になった `FPilot.exe` のバージョン
- 元になった `FPilot.exe` の SHA256 ハッシュ（BAT 実行時のログにも出力されます）

バージョンが異なる EXE に対しては、範囲テーブルの署名が一致せず安全に中断する設計になっています。

## リリース

- タイトル: `Standalone executable v0.8.3` / タグ: `v0.8.3`
- Release: <https://github.com/yuyu1815/fpilot-ja/releases/tag/v0.8.3>
- Release には `FPilot_JA_patch.bat` のみを添付しています (**EXE 本体は添付していません**)。
