import cv2
import mediapipe as mp
import joblib
import numpy as np
from collections import deque, Counter

model = joblib.load("models/gesture_model.pkl")
prediction_history = deque(maxlen=7)

gesture_to_drink = {
    "thumbs_up": "Americano",
    "peace": "Latte",
    "ok": "Mocha",
    "open_palm": "Cappuccino",
}

mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7,
)
mp_draw = mp.solutions.drawing_utils

camera = cv2.VideoCapture(0)

drink = "Gesture not recognized"
confidence = 0.0

while True:
    success, frame = camera.read()

    if not success:
        break

    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
    results = hands.process(rgb)

    if results.multi_hand_landmarks:
        hand = results.multi_hand_landmarks[0]

        mp_draw.draw_landmarks(frame, hand, mp_hands.HAND_CONNECTIONS)

        landmarks = []
        for point in hand.landmark:
            landmarks.extend([point.x, point.y, point.z])

        sample = np.array(landmarks).reshape(1, -1)
        prediction = model.predict(sample)[0]
        prediction_history.append(prediction)

        stable_prediction = Counter(prediction_history).most_common(1)[0][0]
        confidence = np.max(model.predict_proba(sample)) * 100

        if confidence >= 30:
            drink = gesture_to_drink.get(stable_prediction, "Gesture not recognized")
        else:
            drink = "Gesture not recognized"

    overlay = frame.copy()
    cv2.rectangle(overlay, (10, 10), (420, 150), (40, 40, 40), -1)
    cv2.addWeighted(overlay, 0.6, frame, 0.4, 0, frame)

    cv2.putText(
        frame,
        "AI Drive-Thru Gesture",
        (25, 40),
        cv2.FONT_HERSHEY_DUPLEX,
        0.8,
        (255, 255, 255),
        2,
    )
    cv2.putText(
        frame,
        f"Drink : {drink}",
        (25, 75),
        cv2.FONT_HERSHEY_DUPLEX,
        0.8,
        (0, 255, 255),
        2,
    )
    cv2.putText(
        frame,
        f"Confidence : {confidence:.1f}%",
        (25, 105),
        cv2.FONT_HERSHEY_DUPLEX,
        0.75,
        (255, 255, 255),
        2,
    )

    cv2.imshow("Drive Thru AI", frame)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

camera.release()
cv2.destroyAllWindows()
