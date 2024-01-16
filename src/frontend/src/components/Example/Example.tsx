import styles from "./Example.module.css";

interface Props {
    text: string;
    value: string;
    onClick: (value: string) => void;
}

export const Example = ({ text, value, onClick }: Props) => {
    return (
        <div className={styles.example} onClick={() => onClick(value)}>
            <p className={styles.exampleText}><span>{text}</span></p>
        </div>
    );
};

export const ExampleSide = ({ text, value, onClick }: Props) => {
    return (
        <div className={styles.exampleSide} onClick={() => onClick(value)}>
            <p className={styles.exampleText}><span>{text}</span></p>
        </div>
    );
};

