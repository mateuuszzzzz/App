import React from 'react';
import {View} from 'react-native';
import FullScreenLoadingIndicator from '@components/FullscreenLoadingIndicator';
import HeaderWithBackButton from '@components/HeaderWithBackButton';
import ScreenWrapper from '@components/ScreenWrapper';
import useLocalize from '@hooks/useLocalize';
import useThemeStyles from '@hooks/useThemeStyles';

type WorkspaceOwnerChangePageProps = {
    policyID: string;
};

function WorkspaceOwnerChangePage({policyID}: WorkspaceOwnerChangePageProps) {
    const styles = useThemeStyles();
    const {translate} = useLocalize();
    const isLoading = true;

    return (
        <ScreenWrapper testID="WorkspaceOwnerChangePage">
            <HeaderWithBackButton
                title={translate('workspace.changeOwner.changeOwnerPageTitle')}
            />
            <View style={[styles.containerWithSpaceBetween]}>
                {isLoading && <FullScreenLoadingIndicator />}
                {!isLoading && (
                    <View>
                        {/* Owner change content */}
                    </View>
                )}
            </View>
        </ScreenWrapper>
    );
}

WorkspaceOwnerChangePage.displayName = 'WorkspaceOwnerChangePage';

export default WorkspaceOwnerChangePage;
