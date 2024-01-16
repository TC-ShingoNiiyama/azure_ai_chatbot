import { useMemo, useRef } from "react";
import { Stack, Text } from "@fluentui/react";
import DOMPurify from "dompurify";


import styles from "./Answer.module.css";

import { ChatResponse } from "../../api";
import { parseChatAnswerToHtml } from "./AnswerParser";
import { AnswerIcon } from "./AnswerIcon";

interface Props {
    answer: ChatResponse;
    isSelected?: boolean;
    gptModel: string;
}
export const AnswerChat = ({ answer, gptModel, isSelected }: Props) => {
    const parsedAnswer = useMemo(() => parseChatAnswerToHtml(answer.answer), [answer]);
    const parsedGptModel = useRef(gptModel.toString());

    const sanitizedAnswerHtml = DOMPurify.sanitize(parsedAnswer.answerHtml);

    return (
        <Stack className={ parsedGptModel.current.startsWith('gpt-4') ? `${styles.answerContainerGPT4} ${styles.answerContainerGPT3}` : `${isSelected && styles.selected} ${styles.answerContainerGPT3}`} verticalAlign="space-between">
            <Stack.Item>
                <Stack horizontal horizontalAlign="start">
                    <AnswerIcon />
                    <Text>
                        { parsedGptModel.current }
                    </Text>
                </Stack>
            </Stack.Item>

            <Stack.Item grow>
                <div className={styles.answerText} dangerouslySetInnerHTML={{ __html: sanitizedAnswerHtml }}></div>
            </Stack.Item>
        </Stack>
    );
};
