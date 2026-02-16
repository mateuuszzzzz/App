import React from 'react';
import {View} from 'react-native';
import FullscreenLoadingIndicator from '@components/FullscreenLoadingIndicator';
import HeaderWithBackButton from '@components/HeaderWithBackButton';
import ScreenWrapper from '@components/ScreenWrapper';
import useLocalize from '@hooks/useLocalize';
import useThemeStyles from '@hooks/useThemeStyles';
import Navigation from '@libs/Navigation/Navigation';
import ROUTES from '@src/ROUTES';

type WorkspaceSubscriptionPageProps = {
    policyID: string;
};

function WorkspaceSubscriptionPage({policyID}: WorkspaceSubscriptionPageProps) {
    const styles = useThemeStyles();
    const {translate} = useLocalize();
    const isLoading = true; // simplified for test

    return (
        <ScreenWrapper testID="WorkspaceSubscriptionPage">
            <HeaderWithBackButton
                title={translate('workspace.common.subscription')}
                onBackButtonPress={() => Navigation.goBack(ROUTES.SETTINGS)}
            />
            <View style={[styles.flex1]}>
                {isLoading && <FullscreenLoadingIndicator />}
                {!isLoading && (
                    <View>
                        {/* Subscription content */}
                    </View>
                )}
            </View>
        </ScreenWrapper>
    );
}

WorkspaceSubscriptionPage.displayName = 'WorkspaceSubscriptionPage';

export default WorkspaceSubscriptionPage;
