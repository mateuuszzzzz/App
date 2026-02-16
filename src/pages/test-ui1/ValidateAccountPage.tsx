import React, {useEffect} from 'react';
import FullscreenLoadingIndicator from '@components/FullscreenLoadingIndicator';
import ScreenWrapper from '@components/ScreenWrapper';
import Navigation from '@libs/Navigation/Navigation';
import * as Session from '@userActions/Session';
import ROUTES from '@src/ROUTES';

type ValidateAccountPageProps = {
    accountID: number;
    validateCode: string;
};

function ValidateAccountPage({accountID, validateCode}: ValidateAccountPageProps) {
    useEffect(() => {
        Session.validateAccount(accountID, validateCode);
    }, [accountID, validateCode]);

    return (
        <ScreenWrapper testID="ValidateAccountPage">
            <FullscreenLoadingIndicator />
        </ScreenWrapper>
    );
}

ValidateAccountPage.displayName = 'ValidateAccountPage';

export default ValidateAccountPage;
