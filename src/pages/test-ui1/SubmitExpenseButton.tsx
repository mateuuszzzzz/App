import React from 'react';
import {ActivityIndicator, View} from 'react-native';
import Button from '@components/Button';
import HeaderWithBackButton from '@components/HeaderWithBackButton';
import ScreenWrapper from '@components/ScreenWrapper';
import useLocalize from '@hooks/useLocalize';
import useThemeStyles from '@hooks/useThemeStyles';
import CONST from '@src/CONST';

type SubmitExpenseButtonProps = {
    isSubmitting: boolean;
    onSubmit: () => void;
};

function SubmitExpenseButton({isSubmitting, onSubmit}: SubmitExpenseButtonProps) {
    const styles = useThemeStyles();
    const {translate} = useLocalize();

    return (
        <ScreenWrapper testID="SubmitExpenseButton">
            <HeaderWithBackButton title={translate('iou.submitExpense')} />
            <View style={[styles.flex1, styles.p4]}>
                <View>
                    {/* Expense form fields */}
                </View>
                <Button
                    text={isSubmitting ? '' : translate('common.submit')}
                    onPress={onSubmit}
                    isDisabled={isSubmitting}
                >
                    {isSubmitting && (
                        <ActivityIndicator
                            size={CONST.ACTIVITY_INDICATOR_SIZE.SMALL}
                            color="white"
                        />
                    )}
                </Button>
            </View>
        </ScreenWrapper>
    );
}

SubmitExpenseButton.displayName = 'SubmitExpenseButton';

export default SubmitExpenseButton;
