from solid2 import *

# scale([.25,.25,.25])
#     rotate_extrude(angle=360, $fn=250)
#         import("/home/ccaroon/Downloads/chess-profile/Cate-Profile.dxf");
def king():
    king = import_dxf("./images/king/King-Profile.dxf")
    return king                                  \
            .rotate_extrude (angle=360, _fn=250) \
            .scale([.21,.21,.21])
