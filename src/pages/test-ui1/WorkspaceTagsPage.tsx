import React from 'react';
import {View} from 'react-native';
import FullscreenLoadingIndicator from '@components/FullscreenLoadingIndicator';
import HeaderWithBackButton from '@components/HeaderWithBackButton';
import ScreenWrapper from '@components/ScreenWrapper';
import useLocalize from '@hooks/useLocalize';
import Navigation from '@libs/Navigation/Navigation';
import ROUTES from '@src/ROUTES';

type WorkspaceTagsPageProps = {
    policyID: string;
};

function WorkspaceTagsPage({policyID}: WorkspaceTagsPageProps) {
    const {translate} = useLocalize();
    const isLoading = true; // simplified for test

    if (isLoading) {
        return <FullscreenLoadingIndicator shouldUseGoBackButton />;
    }

    return (
        <ScreenWrapper testID="WorkspaceTagsPage">
            <HeaderWithBackButton
                title={translate('workspace.common.tags')}
                onBackButtonPress={() => Navigation.goBack(ROUTES.SETTINGS)}
            />
            <View>
                {/* Tags content */}
            </View>
        </ScreenWrapper>
    );
}

WorkspaceTagsPage.displayName = 'WorkspaceTagsPage';

export default WorkspaceTagsPage;
