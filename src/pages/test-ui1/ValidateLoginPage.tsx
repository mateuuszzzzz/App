import React, {useEffect} from 'react';
import FullscreenLoadingIndicator from '@components/FullscreenLoadingIndicator';
import ScreenWrapper from '@components/ScreenWrapper';
import * as Session from '@userActions/Session';

type ValidateLoginPageProps = {
    accountID: number;
    validateCode: string;
};

function ValidateLoginPage({accountID, validateCode}: ValidateLoginPageProps) {
    useEffect(() => {
        Session.validateLogin(accountID, validateCode);
    }, [accountID, validateCode]);

    return (
        <ScreenWrapper testID="ValidateLoginPage">
            <FullscreenLoadingIndicator shouldUseGoBackButton />
        </ScreenWrapper>
    );
}

ValidateLoginPage.displayName = 'ValidateLoginPage';

export default ValidateLoginPage;
