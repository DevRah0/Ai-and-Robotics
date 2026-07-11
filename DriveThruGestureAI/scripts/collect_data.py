import cv2
import mediapipe as mp
import csv
import os

mp_hands = mp.solutions.hands
hands = mp_hands.Hands(
    static_image_mode=False,
    max_num_hands=1,
    min_detection_confidence=0.7,
    min_tracking_confidence=0.7,
)

mp_draw = mp.solutions.drawing_utils

camera = cv2.VideoCapture(0)

labels = {
    ord("1"): "thumbs_up",
    ord("2"): "peace",
    ord("3"): "ok",
    ord("4"): "open_palm",
}

current_label = "thumbs_up"

os.makedirs("data", exist_ok=True)

csv_path = "data/gesture_dataset.csv"

if not os.path.exists(csv_path):
    with open(csv_path, "w", newline="") as f:
        writer = csv.writer(f)

        header = []

        for i in range(21):
            header.extend([f"x{i}", f"y{i}", f"z{i}"])

        header.append("label")

        writer.writerow(header)

while True:

    success, frame = camera.read()

    if not success:
        break

    rgb = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)

    results = hands.process(rgb)

    landmarks = None

    if results.multi_hand_landmarks:

        hand = results.multi_hand_landmarks[0]

        mp_draw.draw_landmarks(
            frame,
            hand,
            mp_hands.HAND_CONNECTIONS
        )

        landmarks = []

        for point in hand.landmark:
            landmarks.extend([point.x, point.y, point.z])

    key = cv2.waitKey(1) & 0xFF

    if key in labels:
        current_label = labels[key]

    if key == ord("s") and landmarks is not None:

        with open(csv_path, "a", newline="") as f:
            writer = csv.writer(f)
            writer.writerow(landmarks + [current_label])

        print(f"Saved -> {current_label}")

    cv2.putText(
        frame,
        f"Label: {current_label}",
        (10, 35),
        cv2.FONT_HERSHEY_SIMPLEX,
        1,
        (0, 255, 0),
        2,
    )

    cv2.putText(
        frame,
        "1:Thumb  2:Peace  3:OK  4:Palm",
        (10, 70),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        (255, 255, 255),
        2,
    )

    cv2.putText(
        frame,
        "S = Save    Q = Quit",
        (10, 100),
        cv2.FONT_HERSHEY_SIMPLEX,
        0.7,
        (255, 255, 255),
        2,
    )

    cv2.imshow("Collect Dataset", frame)

    if key == ord("q"):
        break

camera.release()
cv2.destroyAllWindows()