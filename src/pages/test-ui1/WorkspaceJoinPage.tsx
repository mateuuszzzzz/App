import React from 'react';
import {View} from 'react-native';
import FullscreenLoadingIndicator from '@components/FullscreenLoadingIndicator';
import HeaderWithBackButton from '@components/HeaderWithBackButton';
import ScreenWrapper from '@components/ScreenWrapper';
import useLocalize from '@hooks/useLocalize';
import useThemeStyles from '@hooks/useThemeStyles';

type WorkspaceJoinPageProps = {
    policyID: string;
    isJoining: boolean;
};

function WorkspaceJoinPage({policyID, isJoining}: WorkspaceJoinPageProps) {
    const styles = useThemeStyles();
    const {translate} = useLocalize();

    if (isJoining) {
        return (
            <ScreenWrapper testID="WorkspaceJoinPage">
                <FullscreenLoadingIndicator />
            </ScreenWrapper>
        );
    }

    return (
        <ScreenWrapper testID="WorkspaceJoinPage">
            <HeaderWithBackButton title={translate('workspace.common.join')} />
            <View style={[styles.flex1]}>
                {/* Join workspace content */}
            </View>
        </ScreenWrapper>
    );
}

WorkspaceJoinPage.displayName = 'WorkspaceJoinPage';

export default WorkspaceJoinPage;
