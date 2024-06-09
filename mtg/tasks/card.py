import re
class Card():

    def __init__(self, name, set_code, type_line, image_uris, faces):
        self.name = name
        self.set_code = set_code
        self.type_line = type_line
        self.image_uris = image_uris
        self.faces = faces


    @property
    def img_base_name(self):
        return re.sub(
            r"\W", "-",
            f"{self.set_code}__{self.name}__{self.type_line}"
        )


    def images(self, img_type):
        images = []
        img_ext = "png" if img_type == "png" else "jpg"

        if self.image_uris:
            img = {
                "file_name": f"{self.img_base_name}__{img_type}.{img_ext}",
                "uri": self.image_uris.get(img_type)
            }
            images.append(img)
        elif self.faces:
            for idx, face in enumerate(self.faces):
                img = {
                    "file_name": f"{self.img_base_name}__{idx+1}__{img_type}.{img_ext}",
                    "uri": face.get("image_uris", {}).get(img_type)
                }
                images.append(img)

        return images
