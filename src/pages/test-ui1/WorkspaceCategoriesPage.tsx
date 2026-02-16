import React from 'react';
import {ActivityIndicator, View} from 'react-native';
import HeaderWithBackButton from '@components/HeaderWithBackButton';
import ScreenWrapper from '@components/ScreenWrapper';
import useLocalize from '@hooks/useLocalize';
import useThemeStyles from '@hooks/useThemeStyles';
import Navigation from '@libs/Navigation/Navigation';
import CONST from '@src/CONST';
import ROUTES from '@src/ROUTES';

type WorkspaceCategoriesPageProps = {
    policyID: string;
};

function WorkspaceCategoriesPage({policyID}: WorkspaceCategoriesPageProps) {
    const styles = useThemeStyles();
    const {translate} = useLocalize();
    const isLoading = true; // simplified for test

    return (
        <ScreenWrapper testID="WorkspaceCategoriesPage">
            <HeaderWithBackButton
                title={translate('workspace.common.categories')}
                onBackButtonPress={() => Navigation.goBack(ROUTES.SETTINGS)}
            />
            {isLoading ? (
                <View style={[styles.flex1, styles.justifyContentCenter, styles.alignItemsCenter]}>
                    <ActivityIndicator size={CONST.ACTIVITY_INDICATOR_SIZE.LARGE} />
                </View>
            ) : (
                <View>
                    {/* Categories list */}
                </View>
            )}
        </ScreenWrapper>
    );
}

WorkspaceCategoriesPage.displayName = 'WorkspaceCategoriesPage';

export default WorkspaceCategoriesPage;
