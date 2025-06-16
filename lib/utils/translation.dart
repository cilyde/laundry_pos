// lib/utils/translations.dart

// lib/utils/translator.dart

import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';

import '../services/LanguageManager.dart';

// String tr(BuildContext context, String key) {
//   final lang = Provider.of<LanguageManager>(context, listen: false).currentLang;
//   return translations[key.toLowerCase()]?[lang] ?? key;
// }


/// Supported languages: English (en), Hindi (hi), Arabic (ar)
// const translations = {
//   // App titles and buttons
//   'title': {
//     'en': 'Laundry Service',
//     'hi': 'लॉन्ड्री सेवा',
//     'ar': 'خدمة الغسيل',
//   },
//   'next': {
//     'en': 'Next',
//     'hi': 'आगे',
//     'ar': 'التالي',
//   },
//   'review': {
//     'en': 'Review Order',
//     'hi': 'आदेश की समीक्षा',
//     'ar': 'مراجعة الطلب',
//   },
//   'confirm_print': {
//     'en': 'Confirm & Print',
//     'hi': 'पुष्टि करें और प्रिंट करें',
//     'ar': 'تأكيد وطباعة',
//   },
//   'done': {
//     'en': 'Done!',
//     'hi': 'पूर्ण!',
//     'ar': 'تم!',
//   },
//
//   // Cloth item keys must match ClothItem.key values
//   'shirt': {
//     'en': 'Shirt',
//     'hi': 'कमीज',
//     'ar': 'قميص',
//   },
//   'pants': {
//     'en': 'Pants',
//     'hi': 'पैंट',
//     'ar': 'بنطال',
//   },
//   'uniform': {
//     'en': 'Uniform',
//     'hi': 'औद्योगिक वर्दी',
//     'ar': 'الزيّ العمالي',
//   },
//   'kanthoora': {
//     'en': 'Kanthoora',
//     'hi': 'कंदूरा',
//     'ar': 'كندورة',
//   },
//   'salwar': {
//     'en': 'Salwar',
//     'hi': 'सलवार',
//     'ar': 'شلوار',
//   },
//   'bedsheet': {
//     'en': 'Bedsheet',
//     'hi': 'चादर',
//     'ar': 'ملاءة سرير',
//   },
//   'inner garment': {
//     'en': 'Inner Garment',
//     'hi': 'अंतर्वस्त्र',
//     'ar': 'ملابس داخلية',
//   },
//   'single blanket': {
//     'en': 'Single Blanket',
//     'hi': 'सिंगल कंबल',
//     'ar': 'بطانية فردية',
//   },
//   'double blanket': {
//     'en': 'Double Blanket',
//     'hi': 'डबल कंबल',
//     'ar': 'بطانية مزدوجة',
//   },
//   'pillow covers': {
//     'en': 'Pillow Covers',
//     'hi': 'तकिया कवर',
//     'ar': 'غطاء الوسادة',
//   },
//   'suit': {
//     'en': 'Suit',
//     'hi': 'सूट',
//     'ar': 'بدلة',
//   },
//
//   // Service types
//   'wash': {
//     'en': 'Wash',
//     'hi': 'धुलाई',
//     'ar': 'غسل',
//   },
//   'iron': {
//     'en': 'Iron',
//     'hi': 'प्रेस',
//     'ar': 'كي',
//   },
//   'both': {
//     'en': 'Both',
//     'hi': 'दोनों',
//     'ar': 'كلاهما',
//   },
//   'wash & iron': {
//     'en': 'Wash & Iron',
//     'hi': 'धुलाई और इस्त्री',
//     'ar': 'غسيل وكيّ',
//   },
//
//   // Review screen labels
//   'review order': {
//     'en': 'Review Order',
//     'hi': 'ऑर्डर की समीक्षा करें',
//     'ar': 'مراجعة الطلب',
//   },
//   'No items in the order': {
//     'en': 'No items in the order',
//     'hi': 'ऑर्डर में कोई आइटम नहीं है',
//     'ar': 'لا توجد عناصر في الطلب',
//   },
//   'total': {
//     'en': 'Total',
//     'hi': 'कुल',
//     'ar': 'المجموع',
//   },
//   'phone': {
//     'en': 'Phone (optional)',
//     'hi': 'फोन (वैकल्पिक)',
//     'ar': 'الهاتف (اختياري)',
//   },
//   'select_service': {
//     'en': 'Select Service',
//     'hi': 'सेवा चुनें',
//     'ar': 'اختر الخدمة',
//   },
//   'quantity': {
//     'en': 'Quantity',
//     'hi': 'मात्रा',
//     'ar': 'الكمية',
//   },
//   'selected items':{
//     'en':'Selected Items',
//     'hi':'चयनित आइटम',
//     'ar':'العناصر المحددة'
//   },
//   'service':{
//     'en':'Service',
//     'hi':'सेवा',
//     'ar':'الخدمة'
//   },
//   'no items selected to wash':{
//     'en':'No items selected to wash',
//     'hi':'धोने के लिए कोई आइटम चयनित नहीं है',
//     'ar':'لم يتم اختيار أي عنصر للغسيل'
//   },
//   'no items selected to iron':{
//     'en':'No items selected to iron',
//     'hi':'इस्त्री करने के लिए कोई आइटम चयनित नहीं है',
//     'ar':'لم يتم اختيار أي عنصر للكيّ'
//   },
//   'no items selected to both':{
//     'en':'No items selected to wash and iron',
//     'hi':'धोने और इस्त्री करने के लिए कोई आइटम चयनित नहीं है',
//     'ar':'لم يتم اختيار أي عنصر للغسيل والكيّ'
//   }
// };
const translations = {
  // App titles and buttons
  'title': {
    'en': 'Laundry Service',
    'hi': 'लॉन्ड्री सेवा',
    'ar': 'خدمة الغسيل',
    'ur': 'لانڈری سروس',
  },
  'next': {
    'en': 'Next',
    'hi': 'आगे',
    'ar': 'التالي',
    'ur': 'اگلا',
  },
  'review': {
    'en': 'Review Order',
    'hi': 'आदेश की समीक्षा',
    'ar': 'مراجعة الطلب',
    'ur': 'آرڈر کا جائزہ',
  },
  'confirm_print': {
    'en': 'Confirm & Print',
    'hi': 'पुष्टि करें और प्रिंट करें',
    'ar': 'تأكيد وطباعة',
    'ur': 'تصدیق کریں اور پرنٹ کریں',
  },
  'done': {
    'en': 'Done!',
    'hi': 'पूर्ण!',
    'ar': 'تم!',
    'ur': 'مکمل!',
  },

  // Cloth item keys must match ClothItem.key values
  'shirt': {
    'en': 'Shirt',
    'hi': 'कमीज',
    'ar': 'قميص',
    'ur': 'قمیض',
  },
  'pants': {
    'en': 'Pants',
    'hi': 'पैंट',
    'ar': 'بنطال',
    'ur': 'پینٹ',
  },
  'uniform': {
    'en': 'Uniform',
    'hi': 'औद्योगिक वर्दी',
    'ar': 'الزيّ العمالي',
    'ur': 'وردی',
  },
  'kanthoora': {
    'en': 'Kanthoora',
    'hi': 'कंदूरा',
    'ar': 'كندورة',
    'ur': 'کندورہ',
  },
  'salwar': {
    'en': 'Salwar',
    'hi': 'सलवार',
    'ar': 'شلوار',
    'ur': 'شلوار',
  },
  'bedsheet': {
    'en': 'Bedsheet',
    'hi': 'चादर',
    'ar': 'ملاءة سرير',
    'ur': 'چادر',
  },
  'inner garment': {
    'en': 'Inner Garment',
    'hi': 'अंतर्वस्त्र',
    'ar': 'ملابس داخلية',
    'ur': 'اندرونی لباس',
  },
  'single blanket': {
    'en': 'Single Blanket',
    'hi': 'सिंगल कंबल',
    'ar': 'بطانية فردية',
    'ur': 'سنگل کمبل',
  },
  'double blanket': {
    'en': 'Double Blanket',
    'hi': 'डबल कंबल',
    'ar': 'بطانية مزدوجة',
    'ur': 'ڈبل کمبل',
  },
  'pillow covers': {
    'en': 'Pillow Covers',
    'hi': 'तकिया कवर',
    'ar': 'غطاء الوسادة',
    'ur': 'تکیے کے غلاف',
  },
  'suit': {
    'en': 'Suit',
    'hi': 'सूट',
    'ar': 'بدلة',
    'ur': 'سوٹ',
  },

  // Service types
  'wash': {
    'en': 'Wash',
    'hi': 'धुलाई',
    'ar': 'غسل',
    'ur': 'دھلائی',
  },
  'iron': {
    'en': 'Iron',
    'hi': 'प्रेस',
    'ar': 'كي',
    'ur': 'استری',
  },
  'both': {
    'en': 'Both',
    'hi': 'दोनों',
    'ar': 'كلاهما',
    'ur': 'دونوں',
  },
  'wash & iron': {
    'en': 'Wash & Iron',
    'hi': 'धुलाई और इस्त्री',
    'ar': 'غسيل وكيّ',
    'ur': 'دھلائی اور استری',
  },

  // Review screen labels
  'review order': {
    'en': 'Review Order',
    'hi': 'ऑर्डर की समीक्षा करें',
    'ar': 'مراجعة الطلب',
    'ur': 'آرڈر کا جائزہ لیں',
  },
  'No items in the order': {
    'en': 'No items in the order',
    'hi': 'ऑर्डर में कोई आइटम नहीं है',
    'ar': 'لا توجد عناصر في الطلب',
    'ur': 'آرڈر میں کوئی آئٹم نہیں ہے',
  },
  'total': {
    'en': 'Total',
    'hi': 'कुल',
    'ar': 'المجموع',
    'ur': 'کل',
  },
  'phone': {
    'en': 'Phone (optional)',
    'hi': 'फोन (वैकल्पिक)',
    'ar': 'الهاتف (اختياري)',
    'ur': 'فون (اختیاری)',
  },
  'select_service': {
    'en': 'Select Service',
    'hi': 'सेवा चुनें',
    'ar': 'اختر الخدمة',
    'ur': 'سروس منتخب کریں',
  },
  'quantity': {
    'en': 'Quantity',
    'hi': 'मात्रा',
    'ar': 'الكمية',
    'ur': 'مقدار',
  },
  'selected items': {
    'en': 'Selected Items',
    'hi': 'चयनित आइटम',
    'ar': 'العناصر المحددة',
    'ur': 'منتخب آئٹمز',
  },
  'service': {
    'en': 'Service',
    'hi': 'सेवा',
    'ar': 'الخدمة',
    'ur': 'سروس',
  },
  'no items selected to wash': {
    'en': 'No items selected to wash',
    'hi': 'धोने के लिए कोई आइटम चयनित नहीं है',
    'ar': 'لم يتم اختيار أي عنصر للغسيل',
    'ur': 'دھونے کے لیے کوئی آئٹم منتخب نہیں کیا گیا',
  },
  'no items selected to iron': {
    'en': 'No items selected to iron',
    'hi': 'इस्त्री करने के लिए कोई आइटम चयनित नहीं है',
    'ar': 'لم يتم اختيار أي عنصر للكيّ',
    'ur': 'استری کے لیے کوئی آئٹم منتخب نہیں کیا گیا',
  },
  'no items selected to both': {
    'en': 'No items selected to wash and iron',
    'hi': 'धोने और इस्त्री करने के लिए कोई आइटम चयनित नहीं है',
    'ar': 'لم يتم اختيار أي عنصر للغسيل والكيّ',
    'ur': 'دھونے اور استری کے لیے کوئی آئٹم منتخب نہیں کیا گیا',
  }
};
