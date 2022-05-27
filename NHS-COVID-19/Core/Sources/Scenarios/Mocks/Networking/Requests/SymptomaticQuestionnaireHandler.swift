//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct SymptomaticQuestionnaireHandler: RequestHandler {
    var paths = ["/distribution/symptomatic-questionnaire"]
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        Result.success(.ok(with: .json(questionnaire)))
    }
}

private let questionnaire = """
{
  "symptoms": [
    {
      "title": {
        "en-GB": "A high temperature (fever)",
        "cy-GB": "Tymheredd uchel (twymyn)",
        "bn-BD": "উচ্চ তাপমাত্রা (জ্বর)",
        "gu-IN": "ઉંચુ તાપમાન (તાવ)",
        "pa-IN": "ਉੱਚ ਤਾਪਮਾਨ (ਬੁਖ਼ਾਰ)",
        "ur-PK": "زیادہ درجہ حرارت (بخار)"
      },
      "description": {
        "en-GB": "This means that you feel hot to touch on your chest or back (you do not need to measure your temperature).",
        "cy-GB": "Mae hyn yn golygu eich bod yn teimlo'n boeth i'ch cyffwrdd ar eich brest neu'ch cefn (nid oes angen i chi fesur eich tymheredd).",
        "bn-BD": "এর অর্থ আপনার বুক বা পিঠে স্পর্শ করলে উষ্ণ বোধ হয় (আপনাকে আপনার তাপমাত্রা পরিমাপ করার প্রয়োজন নেই)।",
        "gu-IN": "આનો મતલબ કે તમને છાતી કે પીઠ પર સ્પર્શ કરતા ગરમ અનુભવાય (તમારે તાપમાન માપવાની જરુર નથી).",
        "pa-IN": "ਇਸਦਾ ਮਤਲਬ ਹੁੰਦਾ ਹੈ ਕਿ ਆਪਣੀ ਛਾਤੀ ਜਾਂ ਪਿੱਠ ਨੂੰ ਛੂਹਣ 'ਤੇ ਤੁਸੀਂ ਗਰਮ ਮਹਿਸੂਸ ਹੁੰਦੇ ਹੋ (ਤੁਹਾਨੂੰ ਆਪਣੇ ਤਾਪਮਾਨ ਨੂੰ ਮਾਪਣ ਦੀ ਜ਼ਰੂਰਤ ਨਹੀਂ ਹੈ)।",
        "ur-PK": "اس کا مطلب یہ ہے کہ آپ کو اپنے سینے یا پیٹھ کو چھونے پر گرم محسوس ہوتا ہے (آپ کو اپنے درجہ حرارت کی پیمائش کرنے کی ضرورت نہیں ہے)۔"
      },
      "riskWeight": 1
    },
    {
      "title": {
        "en-GB": "A new continuous cough",
        "cy-GB": "Peswch parhaus newydd",
        "bn-BD": "নতুন একটানা কাশি",
        "gu-IN": "નવો સતત કફ",
        "pa-IN": "ਨਵੀਂ ਲੱਗੀ ਲਗਾਤਾਰ ਆਉਣ ਵਾਲੀ ਖਾਂਸੀ",
        "ur-PK": "نئی مسلسل کھانسی"
      },
      "description": {
        "en-GB": "This means coughing a lot for more than an hour, or 3 or more coughing episodes in 24 hours (if you usually have a cough, it may be worse than usual).",
        "cy-GB": "Mae hyn yn golygu pesychu llawer am fwy nag awr, neu 3 chyfnod pesychu neu fwy o fewn 24 awr (os oes gennych beswch fel arfer, gallai fod yn waeth nag arfer).",
        "bn-BD": " এর অর্থ এক ঘণ্টারও বেশি সময় ধরে খুব কাশি, বা 24 ঘন্টার মধ্যে 3 বা ততোধিক কাশির পর্ব (আপনার যদি সাধারণ কাশি থেকে থাকে তবে এটি হয়তো স্বাভাবিকের চেয়েও খারাপ হতে পারে)।   ",
        "gu-IN": "આનો મતલબ કે એક કલાક કરતા વધુ સમય માટે કફ ચાલુ કહે કે 24 કલાકમાં 3 વાર કફ આવે (સામાન્યરીતે તમને કફ આવતો હોય તો સ્થિતિ સામાન્ય કરતા ખરાબ હોઈ શકે છે).",
        "pa-IN": "ਇਸਦਾ ਮਤਲਬ ਹੈ ਇੱਕ ਘੰਟੇ ਤੋਂ ਵੱਧ ਸਮੇਂ ਲਈ ਖੰਘ ਆਉਣਾ, ਜਾਂ 24 ਘੰਟਿਆਂ ਵਿੱਚ 3 ਜਾਂ ਵਧੇਰੇ ਖੰਘ ਦੇ ਦੌਰ ਆਉਣਾ (ਜੇ ਤੁਹਾਨੂੰ ਆਮ ਤੌਰ 'ਤੇ ਖੰਘ ਹੁੰਦੀ ਹੈ, ਤਾਂ ਇਹ ਆਮ ਨਾਲੋਂ ਬਦਤਰ ਹੋ ਸਕਦੀ ਹੈ)।",
        "ur-PK": "اس کا مطلب یہ ہے کہ آپ ایک گھنٹے سے زیادہ دیر تک بہت زیادہ کھانستے ہیں یا 24 گھنٹے میں کھانسنے کا سلسلہ 3 یا اس سے زائد بار پیش آتا ہے (اگر آپ کو عموماً کھانسی رہتی ہے تو یہ معمول سے زیادہ بدتر ہو سکتی ہے)۔"
      },
      "riskWeight": 1
    },
    {
      "title": {
        "en-GB": "A new loss or change to your sense of smell or taste",
        "cy-GB": "Colli synnwyr arogli neu flasu neu newid yn y synhwyrau hynny",
        "bn-BD": "আপনার গন্ধ বা স্বাদের অনুভূতির পরিবর্তন বা অনুভূতি হারানো",
        "gu-IN": "તમારી ધ્રાણેન્દ્રિય કે સ્વાદમાં નવી ક્ષતિ કે બદલાવ",
        "pa-IN": "ਗੰਧ ਜਾਂ ਸਵਾਦ ਵਿੱਚ ਨਵੀਂ-ਨਵੀਂ ਆਈ ਕਮੀ ਜਾਂ ਬਦਲਾਅ",
        "ur-PK": "آپ کے بو یا ذائقہ کی حس کا نئے طریقے سے ختم یا تبدیل ہونا"
      },
      "description": {
        "en-GB": "This means you have noticed you cannot smell or taste anything, or things smell or taste different to normal.",
        "cy-GB": "Mae hyn yn golygu eich bod wedi sylwi na allwch arogli na blasu unrhyw beth, neu fod pethau'n arogli neu'n blasu'n wahanol i'r arfer.",
        "bn-BD": "এর অর্থ আপনি লক্ষ্য করেছেন যে আপনি কোনও কিছুর গন্ধ বা স্বাদ পাচ্ছেন না বা জিনিসের গন্ধ বা স্বাদ স্বাভাবিকের থেকে আলাদা।  ",
        "gu-IN": "આનો મતલબ કે તમારા ધ્યાન પર આવ્યુ છે કે તમારુ નાક કશુ સુંધી શકતું નથી કે કશાનો સ્વાદ આવતો નથી કે સામાન્ય સ્થિતિ કરતા અલગ પ્રકારે સ્વાદ અને સુગંધ આવે છે.",
        "pa-IN": "ਇਸ ਦਾ ਅਰਥ ਹੈ ਕਿ ਤੁਸੀਂ ਨੋਟ ਕੀਤਾ ਹੈ ਕਿ ਤੁਸੀਂ ਕਿਸੇ ਚੀਜ਼ ਦੀ ਗੰਧ ਜਾਂ ਸਵਾਦ ਨਹੀਂ ਲੈ ਸਕਦੇ, ਜਾਂ ਸੁੰਘਣ 'ਤੇ ਚੀਜ਼ਾਂ ਵਿੱਚੋਂ ਸਧਾਰਨ ਨਾਲੋਂ ਵੱਖਰੀ ਗੰਧ ਆਉਂਦੀ ਹੈ।",
        "ur-PK": "اس کا مطلب ہے کہ آپ کو یہ محسوس ہوا ہے کہ آپ کوئی چیز سونگھ نہیں سکتے یا کسی چیز کا ذائقہ معلوم نہیں ہو رہا ہے یا پھر چیزوں کی بو یا ذائقہ معمول سے الگ معلوم ہو رہا ہے۔"
      },
      "riskWeight": 1
    }
  ],
  "cardinal": {
    "title": {
      "ar": "",
      "bn": "",
      "cy": "",
      "en": "Do you have a high temperature?",
      "gu": "",
      "pa": "",
      "pl": "",
      "ro": "",
      "so": "",
      "tr": "",
      "ur": "",
      "zh": ""
    }
  },
  "noncardinal": {
    "title": {
      "ar": "",
      "bn": "",
      "cy": "",
      "en": "Do you have any of these symptoms?",
      "gu": "",
      "pa": "",
      "pl": "",
      "ro": "",
      "so": "",
      "tr": "",
      "ur": "",
      "zh": ""
    },
    "description": {
      "ar": "",
      "bn": "",
      "cy": "",
      "en": "Shivering or chills\\n\\nA new, continuous cough\\n\\nA loss or change to your sense of smell or taste\\n\\nShortness of breath\\n\\nFeeling tired or exhausted\\n\\nAn aching body\\n\\nA headache\\n\\nA sore throat\\n\\nA blocked or runny nose\\n\\nLoss of appetite\\n\\nDiarrhoea\\n\\nFeeling sick or being sick",
      "gu": "",
      "pa": "",
      "pl": "",
      "ro": "",
      "so": "",
      "tr": "",
      "ur": "",
      "zh": ""
    }
  },
  "riskThreshold": 0.5,
  "symptomsOnsetWindowDays": 6
}
"""
