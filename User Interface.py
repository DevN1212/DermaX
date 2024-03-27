import customtkinter 
import tkinter as tk
from customtkinter  import filedialog
from PIL import ImageTk,Image
import os
import cv2
import tensorflow as tf
from sklearn.metrics import accuracy_score, classification_report
import numpy as np
import webbrowser


def changeimage():
    global windowfilename 
    windowfilename = filedialog.askopenfilename(initialdir="Desktop/Skin Disease ML/images",title="Select a file",filetypes=(("jpg files","*.jpg"),("all files","*.*")))
    # label_filename = Label(window,text=windowfilename)
    # label_filename.pack()
    img = Image.open(windowfilename)
    img = img.resize((250,250))
    my_image = ImageTk.PhotoImage(img)
    my_image_label.configure(image=my_image)
    my_image_label.image = my_image
    docbutton = customtkinter.CTkButton(master=window,text='Find Doctors Nearby',command=clinic,width=200,height=30)
    docbutton.pack(side = customtkinter.RIGHT,pady=40,padx = 90)
    button = customtkinter.CTkButton(master=window,text='Diagnose',command=diagnose,width=200,height=30)
    button.pack(side = customtkinter.LEFT,pady = 40,padx = 90)
    

def diagnose():
    model = tf.keras.models.load_model('skin_disease_model.h5')

    image = Image.open(windowfilename)
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
    list = ['Atopic Dermatitis','Basal Cell Carcinoma (BCC)','Benign Keratosis-like Lesions','Eczema','Melanocytic Nevi (NV)','Psoriasis','Seborrheic Keratoses and other Benign Tumors','Vitiligo','Warts Molluscum and other Viral Infections']
    print(maxprob)
    maxprob = int(maxprob*100)
    label_disease.configure(text=f'You are diagnosed with {list[a]}')
    label_prob.configure(text=f'Probability is {maxprob}%')

    # print(f'Predicted Class: {predicted_class}')
    # print(f'Predicted Value: {predicted_value}')

def clinic():
        webbrowser.open_new_tab('https://www.google.com/maps/search/skin+doctors+near+me/')

window  = customtkinter.CTk()
window.geometry("800x600")

customtkinter.set_appearance_mode("System")

# Supported themes : green, dark-blue, blue
customtkinter.set_default_color_theme("green")


titlelabel = customtkinter.CTkLabel(master=window,text='Skin Disease Detection',font=("Arial",38,"bold"))
titlelabel.pack(side = customtkinter.TOP)

openfilebutton = customtkinter.CTkButton(master=window,text='Insert image',command=changeimage)
openfilebutton.pack(pady = 20)

my_image_label = customtkinter.CTkLabel(master=window,image='',text='')
my_image_label.pack()

label_disease = customtkinter.CTkLabel(master=window,text='',font=("Arial",23))
label_disease.pack(pady = 15)

label_prob = customtkinter.CTkLabel(master=window,text='',font=("Arial",20))
label_prob.pack()

label_caution = customtkinter.CTkLabel(master=window,text='The results might not be accurate. Always consult a doctor for treatment.',font=("Helvetica",15),text_color='orange')
label_caution.pack(side = customtkinter.BOTTOM,pady = 5)
# button = customtkinter.CTkButton(master=window,text='Diagnose',command=diagnose)
# button.pack(side = customtkinter.BOTTOM,pady = 20)

# docbutton = customtkinter.CTkButton(master=window,text='Find Doctors Nearby',command=clinic)
# docbutton.pack(pady = 20)
window.mainloop()