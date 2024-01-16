import { useState } from "react";
import { Outlet, NavLink, Link } from "react-router-dom";
import { AccessToken, Claim } from "../../api";

import styles from "./Layout.module.css";

const Layout = () => {
    const [loginUser, setLoginUser] = useState<string>("");

    const getLoginUserName = async () => {

        try {
            const result = await fetch("/.auth/me");

            const response: AccessToken[] = await result.json();
            const loginUserClaim = response[0].user_claims.find((claim: Claim) => claim.typ === "name");
            if (loginUserClaim) setLoginUser(loginUserClaim.val);
            else setLoginUser(response[0].user_id);
        } catch (e) {
            setLoginUser("anonymous");
        }
    };

    getLoginUserName();

    return (
        <div className={styles.layout}>
            <header className={styles.header} role={"banner"}>
                <div className={styles.headerContainer}>
                    <Link to="/" className={styles.headerLeftContainer}>
                        <h3 className={styles.headerTitleLeft}>社内ChatGPT</h3>
                    </Link>
                    <nav className={styles.hearderCenterContainer}>
                        <ul className={styles.headerNavList}>
                            <li>
                                <NavLink to="/" className={({ isActive }) => (isActive ? styles.headerNavPageLinkActive : styles.headerNavPageLink)}>
                                    社内向けChat
                                </NavLink>
                            </li>
                            <li className={styles.headerNavLeftMargin}>
                                <NavLink to="/docsearch" className={({ isActive }) => (isActive ? styles.headerNavPageLinkActive : styles.headerNavPageLink)}>
                                    社内文書検索
                                </NavLink>
                            </li>
                        </ul>
                    </nav>
                    <div className={styles.headerRightContainer}>
                        <h4 className={styles.headerRightText}>{loginUser}</h4>
                    </div>
                </div>
            </header>
            <Outlet />
        </div>
    );
};

export default Layout;
