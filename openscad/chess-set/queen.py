from solid2 import *

# scale([.25,.25,.25])
#     rotate_extrude(angle=360, $fn=250)
#         import("/home/ccaroon/Downloads/chess-profile/Cate-Profile.dxf");
def queen():
    queen = import_dxf("./images/queen/Queen-Profile.dxf")
    return queen                                 \
            .rotate_extrude (angle=360, _fn=250) \
            .scale([.25,.25,.25])
