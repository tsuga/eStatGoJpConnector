
# Power BI 政府統計総合窓口(e-Stat.go.jp) APIコネクタ
本コネクタを使用することで、Power BIから[政府統計総合窓口(e-Stat.go.jp)](https://www.e-stat.go.jp/)に[API機能](https://www.e-stat.go.jp/api/)を利用してアクセスしデータを取得することができます。
This Data Connector for Power BI enables users to connect to [a Portal Site for Japanese Government Statistics (e-Stat.go.jp)](https://www.e-stat.go.jp/en) via its [API feature](https://www.e-stat.go.jp/en/developer).


> このコネクタは、政府統計総合窓口(e-Stat)のAPI機能を使用していますが、サービスの内容は国によって保証されたものではありません。
> This service uses the API feature of e-Stat, but the contents of this
> service are not guaranteed by the Statistics Bureau of Japan.

## インストール方法 / How to install
1.  最新の拡張機能ファイル `eStatGoJpConnector.mez` を [リリースページ](https://github.com/tsuga/eStatGoJpConnector/releases/download/v0.1.0/eStatGoJpConnector.mez)からダウンロードします。
2. 拡張機能ファイルを `[ドキュメント]\Power BI Desktop\Custom Connectors` フォルダにコピーします。
3.  Power BI Desktopを起動します。
4.  左上の**ファイル**から**オプションと設定**に進み、**オプション**を開きます。
5.  **セキュリティ**のタブを開きます。
6.  **データ拡張機能**の設定を **(非推奨) 検証または警告せずに、あらゆる拡張機能の読み込みを許可する**を選択します。
7.  Power BI Desktopを再起動します。

補足: 本コネクタは未認証であるため、セキュリティレベルを下げる必要があります。

![Step 4](https://raw.githubusercontent.com/tsuga/eStatGoJpConnector/master/blobs/setting-1.png)
![Step 6](https://raw.githubusercontent.com/tsuga/eStatGoJpConnector/master/blobs/setting-2.png)

1.  Download the latest extension `eStatGoJpConnector.mez` from [the release page](https://github.com/tsuga/eStatGoJpConnector/releases/download/v0.1.0/eStatGoJpConnector.mez).
2. Copy the extension file into the  `[Documents]\Power BI Desktop\Custom Connectors`  directory
3.  Open Power BI Desktop
4.  Go to File | Options and settings | Options
5.  Go the Security tab
6.  Under  _Data Extensions_, select  _Allow any extension to load without warning or validation_
7.  Restart Power BI Desktop

Note, to load extensions during development, you will need to lower the security level for extensions in Power BI Desktop to enable loading unsigned/uncertified connectors.

## データ取得方法 / How to use

1. e-Statにて、アプリケーションIDを取得します。詳細は[公式FAQ](https://www.e-stat.go.jp/api/api-dev/faq#q_3)をご覧ください。
2. ナビゲーションパネルから**データを取得**をクリックします。
3. 検索窓に**e-Stat**を入力し、コネクタを選択します。
4. 画面の表示に従います。アプリケーションIDの

補足: アプリケーションIDは無料で取得できます。

1. Get Application ID (API key) from e-Stat. For details, see [the official FAQ](https://www.e-stat.go.jp/api/api-dev/faq#q_3) (in Japanese).
2. In Power BI, in the navigator pane, click _Get Data_.
3. Type _e-Stat_ and choose the connector.
4. Follow the instruction. You will be asked to enter the Application ID.
 
 
## 今後の開発予定 / Roadmap

 - Microsoftによる認証取得