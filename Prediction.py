import tensorflow as tf
from sklearn.metrics import accuracy_score, classification_report
from PIL import Image
import numpy as np

model = tf.keras.models.load_model('skin_disease_model.h5')


image = Image.open('smallDataset/eval/Seborrheic Keratoses and other Benign Tumors/t-dermatofibroma-79.jpg')
image = image.resize((224, 224))
image = np.array(image)
image = image / 255.0 
image = image.reshape(1, 224, 224, 3)

prediction = model.predict(image)

predicted_class = np.argmax(prediction)  # For classification tasks
predicted_value = prediction[0] 

maxprob = max(predicted_value)

for i in range(0,len(predicted_value)):
    if predicted_value[i] == maxprob:
        a = i

print(f'Predicted Value: {predicted_value}')

subset_class = ['Atopic Dermatitis','Basal Cell Carcinoma (BCC)','Benign Keratosis-like Lesions (BKL) 2624','Eczema','Melanocytic Nevi (NV)','Psoriasis pictures Lichen Planus and related diseases','Seborrheic Keratoses and other Benign Tumors','Warts Molluscum and other Viral Infections']
print(subset_class[a])
print(maxprob)
