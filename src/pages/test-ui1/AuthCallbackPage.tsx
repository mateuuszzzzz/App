import React, {useEffect} from 'react';
import {ActivityIndicator, View} from 'react-native';
import useThemeStyles from '@hooks/useThemeStyles';
import * as Session from '@userActions/Session';
import CONST from '@src/CONST';

type AuthCallbackPageProps = {
    authToken: string;
};

function AuthCallbackPage({authToken}: AuthCallbackPageProps) {
    const styles = useThemeStyles();

    useEffect(() => {
        Session.signInWithToken(authToken);
    }, [authToken]);

    return (
        <View style={[styles.flex1, styles.justifyContentCenter, styles.alignItemsCenter]}>
            <ActivityIndicator size={CONST.ACTIVITY_INDICATOR_SIZE.LARGE} />
        </View>
    );
}

AuthCallbackPage.displayName = 'AuthCallbackPage';

export default AuthCallbackPage;
