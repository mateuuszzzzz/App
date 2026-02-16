import React, {useContext} from 'react';
import {View} from 'react-native';
import FullscreenLoadingIndicator from '@components/FullscreenLoadingIndicator';
import {FullScreenLoaderContext} from '@components/FullScreenLoaderContextProvider';
import ScreenWrapper from '@components/ScreenWrapper';
import useThemeStyles from '@hooks/useThemeStyles';

function AppLoadingPage() {
    const styles = useThemeStyles();
    const {isLoaderVisible} = useContext(FullScreenLoaderContext);

    return (
        <ScreenWrapper testID="AppLoadingPage">
            <View style={[styles.flex1]}>
                {isLoaderVisible && <FullscreenLoadingIndicator />}
                <View>
                    {/* App content below loader overlay */}
                </View>
            </View>
        </ScreenWrapper>
    );
}

AppLoadingPage.displayName = 'AppLoadingPage';

export default AppLoadingPage;
