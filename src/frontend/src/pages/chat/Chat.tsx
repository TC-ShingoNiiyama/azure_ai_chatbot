import { useRef, useState, useEffect } from "react";
import { TextField, Panel, DefaultButton } from "@fluentui/react";
import { Dropdown, IDropdownOption } from "@fluentui/react/lib/Dropdown";

import styles from "./Chat.module.css";

import { chatApi, Approaches, ChatResponse, GptChatRequest, GptChatTurn } from "../../api";
import { AnswerChat, AnswerError, AnswerLoading } from "../../components/Answer";
import { QuestionInput } from "../../components/QuestionInput";
import { UserChatMessage } from "../../components/UserChatMessage";
import { SettingsButton } from "../../components/SettingsButton";
import { ClearChatButton } from "../../components/ClearChatButton";

const Chat = () => {
    const [isConfigPanelOpen, setIsConfigPanelOpen] = useState(false);

    const [gptModel, setGptModel] = useState<string>("gpt-4-turbo");
    const [systemPrompt, setSystemPrompt] = useState<string>("");
    const [temperature, setTemperature] = useState<string>("0.0");

    const lastQuestionRef = useRef<string>("");
    const chatMessageStreamEnd = useRef<HTMLDivElement | null>(null);

    const [isLoading, setIsLoading] = useState<boolean>(false);
    const [error, setError] = useState<unknown>();

    const [selectedAnswer, setSelectedAnswer] = useState<number>(0);
    const [answers, setAnswers] = useState<[user: string, response: ChatResponse][]>([]);

    const gpt_models: IDropdownOption[] = [
        { key: "gpt-3.5-turbo", text: "gpt-3.5-turbo" },
        { key: "gpt-3.5-turbo-16k", text: "gpt-3.5-turbo-16k" },
        { key: "gpt-4-turbo", text: "gpt-4-turbo" },
        { key: "gpt-4-32k", text: "gpt-4-32k" }
    ];

    const temperatures: IDropdownOption[] = Array.from({ length: 11 }, (_, i) => ({ key: (i / 10).toFixed(1), text: (i / 10).toFixed(1) }));

    const makeApiRequest = async (question: string) => {
        lastQuestionRef.current = question;

        error && setError(undefined);
        setIsLoading(true);

        try {
            const history: GptChatTurn[] = answers.map(a => ({ user: a[0], assistant: a[1].answer }));
            const request: GptChatRequest = {
                history: [...history, { user: question, assistant: undefined }],
                approach: Approaches.Read,
                overrides: {
                    gptModel: gptModel,
                    temperature: temperature,
                    systemPrompt: systemPrompt
                }
            };
            const result = await chatApi(request);
            setAnswers([...answers, [question, result]]);
        } catch (e) {
            setError(e);
        } finally {
            setIsLoading(false);
        }
    };

    const clearChat = () => {
        lastQuestionRef.current = "";
        error && setError(undefined);
        setAnswers([]);
    };

    useEffect(() => chatMessageStreamEnd.current?.scrollIntoView({ behavior: "smooth" }), [isLoading]);

    const onGptModelChange = (_ev?: React.FormEvent<HTMLDivElement>, option?: IDropdownOption) => {
        if (option !== undefined) {
            setGptModel(option.key as string);
        }
    };

    const onSystemPromptChange = (_ev?: React.SyntheticEvent<HTMLElement, Event>, newValue?: string) => {
        setSystemPrompt(newValue || "");
    };

    const onTempertureChange = (_ev?: React.FormEvent<HTMLDivElement>, option?: IDropdownOption) => {
        if (option !== undefined) {
            setTemperature(option.key as string);
        }
    };

    useEffect(() => 
    setSystemPrompt("あなたにはヘルプデスク担当者です。まず「ご用件は何でしょうか？」と聞いてください。以下のルールに基づき回答すること。1 TOKYO GLIPセキュリティーカードの発行 セキュリティ／権限 TC従業員、GLIP勤務 GLIP勤務の人は、TOKYO GLIPセキュリティーカード（以下セキュリティカード）が発行される。 セキュリティカードは、workhubのアカウントと紐づいていて、個人の顔情報が登録されている。 Axleの設備が利用可能” GLIPが発行するセキュリティカードは、黒ストラップ(TC所属を表す）、青ストラップ（TC業務委託を表す） 2 セキュリティーカードの出張者への発行 セキュリティ／権限 TC従業員、GLIP勤務以外、事前申請 「TOKYO GLIPセキュリティーカード/Workhubアカウント貸与申請書」を申請することで、GLIP勤務以外の人でも、セキュリティカードの発行が可能 権限は、No1と同じ” 3 セキュリティーカード（匿名）の出張者への貸与 セキュリティ／権限 TC従業員、GLIP勤務以外 GLIP勤務以外の出張者は、NIC(総務G)もしくはGLIP(東京総務G)でセキュリティカード（匿名）を借りることができる セキュリティカードとの相違点は、workhubのアカウントと紐づいていないので、会議室の予約及び顔認証による入室ができない。” NICでセキュリティカードを借りると、白ストラップ(TC所属、NICから貸与を表す） 　→1FガレージはNIC貸与の白ストラップでも入れる？か確認” 4 ゲストカードのゲストへの貸与 セキュリティ／権限 ゲスト ゲストの方の「来客入室申請」「情報持ち込み申請」の申請を出して、アテンド対応をするTC従業員がゲスト用の赤ストラップを受け取る。 5 セキュリティーカードのゲストへの貸与 セキュリティ／権限 ゲスト、事前申請 「【社外者】 TOKYO GLIP_セキュリティカード・Wh発行依頼書」　兼　本人確認書で承認を受けた社外者は、セキュリティカードの発行が可能 ・5Fプロダクトエリア、RoomC（大部屋）に入室する際はWorkhubアカウントの登録が別途必要 ・1Fガレージに入室する場合は、セキュリティカードの種類が異なるため、入室理由記載必要” 6 Alxeへの入館 入退館 セキュリティカードがない人 平日8:30-21:30に外から入館可能 たまに21:30以前に閉まっている場合がある” 年末年始（12 月 27 日～1 月 5 日）は全館閉館日 7 Alxeへの入館 入退館 セキュリティカードがある人 1Fからセキュリティーカードでビルへの入館可能 入退室は通用口より 24 時間可能です。ただし、設備点検等全館臨時休業日を除くものとします” 8 会議室の予約方法 会議室予約 workhubアカウントのある人 Outlookから予約可能 GLIPは、workhubアカウントと連携させているため、workhubアカウントがない人は予約できない 9 駐車場の予約方法 駐車場予約 １．事前に東京総務Gへの予約メール ２．三角コーンの移動 ３．駐車場許可証の車両ダッシュボード上への提示” 10 駐車場の予約確認方法 駐車場予約 Outlookから予約確認可能 11 5F：出張者ロッカー 設備利用 TC従業員、GLIP勤務以外 出張者用と記載のあるロッカーを利用可能 12 5F：マルシェ 設備利用 ゲスト ゲストは、５Fマルシェ用QRコードを発行してもらう必要がある ５Fマルシェ用QRコードは緑ストラップに入れる運用 13 休憩室 設備利用 予約不要、利用時台帳記入 利用後はファブリーズ必須。本社も週1交換” 14 1Fガレージ利用 設備利用 Outlookから利用予約 TC従業員のセキュリティカードなら入れる。それ以外は申請ベース” ガレージの利用方法は、このページ通り？https://toyotamedia.sharepoint.com/sites/New_Tokyo_Office/SitePages/garage.aspx 15 ６F：ウォーターサーバ・コーヒーサーバ・冷蔵庫 備品利用 任意利用可能 16 Axle設備利用（2Fコーヒーサーバ、ウォーターサーバ） 共用設備利用 黒、白、青ストラップ保持者 黒、白、青ストラップ保持者は、Axleの設備利用可能。ゲスト等は利用権限がないため、黒、白、青ストラップ保持者と同席のもと利用 Axleのオフィス会員（オフィステナント会員）として契約済 17 喫煙所について 喫煙所 館内での喫煙は「喫煙スペース」のみ １F喫煙スペース 「紙巻タバコ専用」と「加熱式タバコ専用」に部屋を分離” 18 ６F：備品棚 備品利用 任意利用可能 19 ファンヒーターの利用 備品利用 台帳記入して利用可能／自分で返却 20 貸与カード、機材（Jabraスピーカーフォン）の返却 備品利用 貸与カード、機材（Jabraスピーカーフォン）の返却ポストに返却 21 来客用GLIPペットボトルのお水の使用時 備品利用 ５個以上使用する場合 在庫調整のため、来客用のGLIPペットボトルのお水を1日5本以上使用される場合は、事前に東京総務に連絡 22 ６F：複合機　FXどこでもプリント(クラウド)でプリンタ利用 備品利用 セキュリティカード セキュリティカードがないと印刷ができない（匿名カードでも大丈夫？） 23 切手、レターパックの利用について 備品利用 換金できる切手・レターパックの管理レベル向上のため、東京総務から受け取る形にする 24 コーポレートカード（クレジットカード）での備品購入 備品購入 経営管理部 経理室 ファイナンスG 連絡先：01E02101＠mail.toyotaconnected.co.jp に連絡 当日は画面を共有しながら、ファイナンスGの方主導でカード番号を入力していただけます。25 カード・セキュリティの緊急連絡先 緊急連絡先 22時以後 SECOM    ０１２０－１０－００２４        お問い合わせ番号：８２９０１７　26 個人ロッカーの緊急連絡先 緊急連絡先 22時以後 コーポレート管理部 東京総務G 　上野GM　27 上記以外の設備等の不具合緊急連絡先 緊急連絡先 22時以後 大成有楽不動産㈱　ビルネックス２４        ０３ー３５６７－９２４３　28 日中（22時まで）の緊急連絡先 緊急連絡先 22時ま　29 宅急便発送受付 締切時間（当日発送分） 宅配便 “■ヤマト運輸　: 14時 30分　　    ■佐川急便　 : 11時 45分　    →発送・到着荷物置き場に置く” 30 発送・到着荷物置き場 宅配便 ６Fオフィスエリア 中央カウンター内 (バックヤード横) 31 ご自身で営業所へ荷物を持ち込まれた際の発送伝票の提出 宅配便 “総務受付時間を過ぎて、当日発送をご希望される方は、ご自身で近隣の営業所までお持ちください。    注 : 営業所へお持ち込みされた場合、発送伝票は、「総務宛て 返却ポスト」へ投函してください。    ★ 「総務宛て 返却ポスト」設置場所 → ６Fオフィスエリア内 備品キャビネット(レターボックス横） 32 仮置き申請 備品仮置き 各部署で購入された備品などの荷物を6Fバックヤード・5Fストックルームで一時的に保管される場合、仮置き申請書を提出いただき保管する運用  33 備品廃棄フロー 備品廃棄 “・廃棄決裁取得済の固定資産    ・部長決裁取得済の会社費用で購入した備品    について、年二回、社内一斉回収⇒廃棄を行います。    保管しておける場所が無い為、基本は都度発注（都度廃棄発注）です。その際は、所属部のPJコードで対応"))

    return (
        <div className={styles.container}>
            <div className={styles.commandsContainer}>
                <ClearChatButton className={styles.commandButton} onClick={clearChat} disabled={!lastQuestionRef.current || isLoading} />
                <Dropdown
                        className={styles.chatSettingsSeparatorFix}
                        defaultSelectedKeys={[gptModel]}
                        selectedKey={gptModel}
                        options={gpt_models}
                        onChange={onGptModelChange}
                    />
            </div>
            <div className={styles.chatRoot}>
                <div className={styles.chatContainer}>
                    <div className={styles.chatMessageStream}>
                        {answers.map((answer, index) => (
                            <div key={index}>
                                <UserChatMessage message={answer[0]} />
                                <div className={styles.chatMessageGpt}>
                                    <AnswerChat key={index} gptModel={gptModel.toString()} answer={answer[1]} isSelected={selectedAnswer === index} />
                                </div>
                            </div>
                        ))}
                        {isLoading && (
                            <>
                                <UserChatMessage message={lastQuestionRef.current} />
                                <div className={styles.chatMessageGptMinWidth}>
                                    <AnswerLoading />
                                </div>
                            </>
                        )}
                        {error ? (
                            <>
                                <UserChatMessage message={lastQuestionRef.current} />
                                <div className={styles.chatMessageGptMinWidth}>
                                    <AnswerLoading />
                                </div>
                            </>
                        ) : null}
                        <div ref={chatMessageStreamEnd} />
                    </div>

                    <div className={styles.chatInput}>
                        <QuestionInput
                            clearOnSend
                            placeholder="企業内向けChatGPTと会話を始めましょう。（例：ChatGPTについて教えて下さい）"
                            disabled={isLoading}
                            onSend={question => makeApiRequest(question)}
                        />
                    </div>
                </div>
                <Panel
                    headerText="Configure GPT settings"
                    isOpen={isConfigPanelOpen}
                    isBlocking={false}
                    onDismiss={() => setIsConfigPanelOpen(false)}
                    closeButtonAriaLabel="Close"
                    onRenderFooterContent={() => <DefaultButton onClick={() => setIsConfigPanelOpen(false)}>Close</DefaultButton>}
                    isFooterAtBottom={true}
                >
                    <Dropdown
                        className={styles.chatSettingsSeparator}
                        defaultSelectedKeys={[gptModel]}
                        selectedKey={gptModel}
                        label="GPT Model:"
                        options={gpt_models}
                        onChange={onGptModelChange}
                    />
                    <TextField
                        className={styles.chatSettingsSeparator}
                        value={systemPrompt}
                        label="System Prompt:"
                        multiline
                        autoAdjustHeight
                        onChange={onSystemPromptChange}
                    />
                    <Dropdown
                        className={styles.chatSettingsSeparator}
                        defaultSelectedKeys={[temperature]}
                        selectedKey={temperature}
                        label="Temperature:"
                        options={temperatures}
                        onChange={onTempertureChange}
                    />
                </Panel>
            </div>
        </div>
    );
};

export default Chat;
