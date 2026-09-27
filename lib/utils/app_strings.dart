enum AppLanguage { english, tamil, sinhala }

class AppStrings {
  final AppLanguage language;
  AppStrings(this.language);

  String _t(String en, String ta, String si) {
    switch (language) {
      case AppLanguage.tamil:
        return ta;
      case AppLanguage.sinhala:
        return si;
      case AppLanguage.english:
        return en;
    }
  }

  String get appTitle => _t('Welcome to Expense Tracker', 'செலவு கண்காணிப்பிற்கு வரவேற்கிறோம்', 'වියදම් ට්‍රැකරයට සාදරයෙන් පිළිගනිමු');
  String get greeting => _t('Hii', 'வணக்கம்', 'ආයුබෝවන්');
  String get subtitle => _t('Track where your money goes', 'உங்கள் பணம் எங்கு செல்கிறது என்பதை கண்காணிக்கவும்', 'ඔබේ මුදල් යන ස්ථානය නිරීක්ෂණය කරන්න');
  String get totalSpent => _t('Total spent this month', 'இந்த மாதம் மொத்த செலவு', 'මෙම මාසයේ මුළු වියදම');
  String get searchHint => _t('Search expenses...', 'செலவுகளைத் தேடு...', 'වියදම් සොයන්න...');
  String get filterByDate => _t('Filter by date', 'தேதி வாரியாக வடிகட்டு', 'දිනය අනුව පෙරහන');
  String get noExpensesYet => _t('No expenses yet', 'இன்னும் செலவுகள் இல்லை', 'තවම වියදම් නැත');
  String get addFirstExpense => _t('Tap the + button to add your first expense', '+ பொத்தானை அழுத்தி உங்கள் முதல் செலவைச் சேர்க்கவும்', 'ඔබේ පළමු වියදම එකතු කිරීමට + බොත්තම ඔබන්න');
  String get addExpense => _t('Add Expense', 'செலவு சேர்', 'වියදම එකතු කරන්න');
  String get editExpense => _t('Edit Expense', 'செலவைத் திருத்து', 'වියදම සංස්කරණය කරන්න');
  String get title => _t('Title', 'தலைப்பு', 'මාතෘකාව');
  String get amount => _t('Amount (Rs.)', 'தொகை (Rs.)', 'මුදල (Rs.)');
  String get category => _t('Category', 'வகை', 'කාණ්ඩය');
  String get date => _t('Date', 'தேதி', 'දිනය');
  String get note => _t('Note (optional)', 'குறிப்பு (விருப்பமானது)', 'සටහන (විකල්පමය)');
  String get saveExpense => _t('Save Expense', 'செலவைச் சேமி', 'වියදම සුරකින්න');
  String get updateExpense => _t('Update Expense', 'செலவைப் புதுப்பி', 'වියදම යාවත්කාලීන කරන්න');
  String get login => _t('Log In', 'உள்நுழை', 'පුරන්න');
  String get signUp => _t("Don't have an account? Sign up", 'கணக்கு இல்லையா? பதிவு செய்யவும்', 'ගිණුමක් නැද්ද? ලියාපදිංචි වන්න');
  String get monthlySummary => _t('Monthly Summary', 'மாதாந்திர சுருக்கம்', 'මාසික සාරාංශය');
}