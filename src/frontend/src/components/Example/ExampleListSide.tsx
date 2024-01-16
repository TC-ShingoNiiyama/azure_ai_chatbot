import { ExampleSide } from "./Example";

import styles from "./Example.module.css";

export type ExampleModel2 = {
    text: string;
    value: string;
};

const EXAMPLES_SIDE: ExampleModel2[] = [
    {
        text: "会議室の利用方法",
        value: "会議室の利用方法は？"
    },
    { text: "ゴミの処理", value: "GLIPのゴミの処理ルールについて教えてください。" },
    { text: "ガレージの利用方法", value: "GLIPのガレージの利用ルールを教えてください。" },
    { text: "ロッカー", value: "GLIPのロッカーについて教えてください。" },
    { text: "オフィスエリア", value: "GLIPのオフィスエリアの利用ルールを教えてください。" },
    { text: "社用車利用方法", value: "GLIPの社用車の利用ルールを教えてください。" },
    { text: "通用口", value: "GLIPの通用口のルールを教えてください。" },
    { text: "服装規定", value: "GLIPの服装規定について教えてください。" },
];

interface Props {
    onExampleClicked: (value: string) => void;
}

export const ExampleListSide = ({ onExampleClicked }: Props) => {
    return (
        <ul className={styles.examplesNavListSide}>
            {EXAMPLES_SIDE.map((x, i) => (
                <li key={i}>
                    <ExampleSide text={x.text} value={x.value} onClick={onExampleClicked} />
                </li>
            ))}
        </ul>
    );
};
