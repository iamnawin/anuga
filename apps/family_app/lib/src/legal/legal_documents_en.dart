import 'legal_document.dart';

// English drafts taken from docs/legal/lawyer-review-pack.md (Parts D and F).
// They are NOT approved. Blanks stay as "[To be confirmed: ...]" until the
// founder and the lawyer supply them; never fill a blank with a guess.

const privacyNoticeEn = LegalDocument.draft(
  kind: LegalDocumentKind.privacyNotice,
  version: '0.1-draft',
  sections: [
    LegalSection('Who we are', [
      'AnugaCare is run by [To be confirmed: legal entity name and registered address]. '
          'We arrange a companion to travel with a patient to dialysis and back home.',
    ]),
    LegalSection('What we collect and why', [
      'Your name, mobile number and language: to log you in and contact you.',
      "The patient's name, date of birth, home address, dialysis centre and mobility needs: "
          'to plan the visit and send the right help.',
      "An emergency contact's name and number: to call them if something goes wrong.",
      "Visit times, visit status and the companion's note: to carry out the visit and keep you informed at every step.",
      'Health documents you choose to upload: to keep them in your private vault. This is optional.',
      'Bills and payment status: to charge for the service and keep the records the law requires.',
      'We collect only what we need for these purposes.',
    ]),
    LegalSection('Who sees it', [
      "Your companion sees the patient's first name, pickup address, centre, visit time and mobility needs, "
          'only around the time of the visit. Your companion never sees health documents, date of birth, bills '
          'or your phone number.',
      'Family members you allow see what their access level permits.',
      'AnugaCare staff see what they need to plan visits, solve problems and bill you. They can open your '
          'health documents only if you turn that permission on, and every view is recorded.',
      'Companies that work for us: [To be confirmed: hosting, messaging, payment and operations providers]. '
          'They may use the data only to provide their service to us.',
      'We do not sell your data. We do not use it for advertising.',
    ]),
    LegalSection('Where it is kept', ['[To be confirmed: storage location, after legal review].']),
    LegalSection('How long we keep it', [
      'While you use AnugaCare. After you leave or ask us to delete your data, we delete it within '
          '[To be confirmed: period], except records the law requires us to keep, such as '
          '[To be confirmed: record types and periods].',
    ]),
    LegalSection('Your choices and rights', [
      'You can see the data we hold about you and the patient.',
      'You can ask us to correct or update it.',
      'You can withdraw any consent at any time in the app under "Privacy and consent". It is as easy as '
          'giving it. If you withdraw consent for trip coordination, we cannot provide visits.',
      'You can ask us to delete your data.',
      'You can name another person to use these rights for you if you die or become unable to.',
      'You can complain to us and, if you are not satisfied, to the Data Protection Board of India.',
    ]),
    LegalSection('How to reach us', [
      'Grievance officer: [To be confirmed: name, email and phone]. '
          'We reply within [To be confirmed: number of days].',
    ]),
    LegalSection('Children and people who cannot decide for themselves', [
      '[To be confirmed: text after legal review].',
    ]),
    LegalSection('Emergencies', [
      'AnugaCare is not an emergency or medical service. In a medical emergency call 112 or 108.',
    ]),
    LegalSection('Changes', [
      'If we change this notice in a way that matters, we will tell you in the app before the change applies, '
          'and ask for consent again where the law requires it.',
    ]),
  ],
);

const termsOfServiceEn = LegalDocument.draft(
  kind: LegalDocumentKind.termsOfService,
  version: '0.1-draft',
  sections: [
    LegalSection('1. Who we are', [
      '"AnugaCare", "we" and "us" mean [To be confirmed: legal entity name]. "You" means the person who opens '
          'the account and anyone who uses it with your permission.',
    ]),
    LegalSection('2. What we provide', [
      "A trained companion goes to the patient's home, travels with the patient to the dialysis centre, hands "
          "the patient to the centre's staff, and brings the patient home after the session.",
    ]),
    LegalSection('3. What we do not provide', [
      'Companions are not doctors, nurses or paramedics. They do not give medical advice, medicines, injections '
          'or treatment, and they do not operate medical equipment. AnugaCare is not an ambulance or emergency service.',
    ]),
    LegalSection('4. Emergencies', [
      'In a medical emergency, call 112 or 108. If an emergency happens during a visit, the companion will call '
          'emergency services and then tell AnugaCare and your emergency contact. AnugaCare does not send emergency help.',
    ]),
    LegalSection('5. Your responsibilities', [
      'Give us correct details about the patient, including mobility needs and anything a companion must know '
          'to travel safely.',
      'Tell us before the visit if the patient is unwell or not fit to travel.',
      'Make sure someone is reachable on the emergency contact number during the visit.',
      'Keep the pickup code private and give it only to the companion at the door.',
    ]),
    LegalSection('6. When a companion may refuse or stop a visit', [
      'A companion may decline to start, or may stop and call for help, if the patient appears too unwell to '
          'travel safely, or if the companion faces abuse or unsafe conditions. '
          '[To be confirmed: charges in this case].',
    ]),
    LegalSection('7. The pickup code', [
      'We confirm the companion at your door with a one-time code. Do not hand over the patient to anyone who '
          'cannot enter the code successfully.',
    ]),
    LegalSection('8. Booking, changes and cancellation', [
      'You can request a visit in the app; a visit is confirmed only when we confirm it. You can cancel in the '
          'app before the companion sets out. [To be confirmed: cancellation charges].',
      'If we cannot provide a confirmed visit, we will tell you as early as we can. [To be confirmed: remedy].',
    ]),
    LegalSection('9. Prices and payment', [
      'Prices are shown before you book. [To be confirmed: travel fare, billing terms, tax and refund terms].',
    ]),
    LegalSection('10. Travel', ['[To be confirmed: who books travel and who is responsible for it].']),
    LegalSection('11. Our responsibility to you', [
      "We will provide the service with reasonable care and skill. We are not responsible for the patient's "
          "medical condition or treatment, for the dialysis centre's services, or for delays caused by traffic, "
          'weather or events outside our control.',
      '[To be confirmed: limit of liability]. Nothing here limits liability that the law does not allow us to limit.',
    ]),
    LegalSection('12. Your data', [
      'Our privacy notice explains what we collect and your choices. Consent for data use is asked separately '
          'in the app and is not part of accepting these terms.',
    ]),
    LegalSection('13. Family access', [
      'The account owner decides who else in the family can see or manage visits. You are responsible for the '
          'people you ask us to add.',
    ]),
    LegalSection('14. Ending the service', [
      'You can stop at any time. We may suspend or end the service if these terms are broken, if bills stay '
          'unpaid, or if we can no longer serve your area. [To be confirmed: notice period].',
    ]),
    LegalSection('15. Complaints', ['[To be confirmed: grievance contact and response times].']),
    LegalSection('16. Changes to these terms', [
      'We will tell you in the app before a change applies. [To be confirmed: notice period].',
    ]),
    LegalSection('17. Law and disputes', [
      'These terms are governed by the laws of India. [To be confirmed: courts or arbitration].',
    ]),
  ],
);
