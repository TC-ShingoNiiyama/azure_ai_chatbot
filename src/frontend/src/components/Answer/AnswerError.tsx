import { Stack, PrimaryButton, Text } from "@fluentui/react";
import { ErrorCircle24Regular } from "@fluentui/react-icons";
import { useMemo, useRef } from "react";

import styles from "./Answer.module.css";

interface Props {
    error: string;
    onRetry: () => void;
}

export const AnswerError = ({ error, onRetry}: Props) => {

    return (
        <Stack className={styles.answerContainer} verticalAlign="space-between">
                <ErrorCircle24Regular aria-hidden="true" aria-label="Error icon" primaryFill="red" />
            <Stack.Item grow>
                <p className={styles.answerTextError}>{error}</p>
            </Stack.Item>
            <PrimaryButton className={styles.retryButton} onClick={onRetry} text="Retry" />
        </Stack>
    );
};
