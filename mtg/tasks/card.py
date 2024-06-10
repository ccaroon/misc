import json
import re

class Card:
    def __init__(self, card_obj):
        self.name = card_obj.get("name")
        self.set_code = card_obj.get("set")
        self.set_number = card_obj.get("collector_number")

        self.__data = card_obj


    @property
    def unique_name(self):
        return re.sub(
            r"\W+", "-",
            f"{self.set_code}_{self.name}_{self.set_number}"
        )


    @property
    def img_base_name(self):
        return re.sub(
            r"\W+", "-",
            f"{self.unique_name}_{self.property('type_line')}"
        )

    
    def dump(self):
        return json.dumps(self.__data, indent=2)

    def images(self, img_type):
        image_uris = self.__data.get("image_uris")
        faces = self.__data.get("card_faces")
        
        img_ext = "png" if img_type == "png" else "jpg"

        images = []
        if image_uris:
            img = {
                "file_name": f"{self.img_base_name}_{img_type}.{img_ext}",
                "uri": image_uris.get(img_type)
            }
            images.append(img)
        elif faces:
            for idx, face in enumerate(faces):
                img = {
                    "file_name": f"{self.img_base_name}_{idx+1}_{img_type}.{img_ext}",
                    "uri": face.get("image_uris", {}).get(img_type)
                }
                images.append(img)

        return images


    def property(self, name, default=None):
        return self.__data.get(name, default)
