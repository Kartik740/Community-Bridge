const path = require('path');
require('dotenv').config({ path: path.join(__dirname, '../../.env') });
const { db } = require('../config/firebase');

async function cleanEmptySurveys() {
    try {
        const surveysSnap = await db.collection('surveys').get();
        let deleted = 0;
        for (const surv of surveysSnap.docs) {
            const surveyId = surv.id;
            const surveyCode = surv.data().surveyCode;
            
            // Check responses for this survey
            const r1 = await db.collection('responses').where('surveyId', '==', surveyId).limit(1).get();
            const r2 = surveyCode ? await db.collection('responses').where('surveyId', '==', surveyCode).limit(1).get() : { empty: true };
            
            if (r1.empty && r2.empty) {
                console.log(`Deleting empty survey: ${surv.data().title || surveyId}`);
                await surv.ref.delete();
                deleted++;
            }
        }
        console.log(`Successfully deleted ${deleted} empty surveys.`);
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}

cleanEmptySurveys();
