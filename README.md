# so101-with-lerobot
[Directly follows lerobot documentation.](https://huggingface.co/docs/lerobot/en/installation)

### and:

adds options to run only single commands if any part of the setup and operation needs to be redone. 

* ex. cameras get unplugged and the ports must be reset

* ex. new setup and the arm and teleop must be re-calibrate

* ex. only want to run teleoperation without typing in all the commands:

  * can run this:

    ```
    ./so101.sh --teleop-only
    ```
  * instead of:
    ```
    lerobot-teleoperate \
    --robot.type=so101_follower \
    --robot.port=/dev/ttyACM1 \
    --robot.id=follower_67 \
    --robot.cameras="{ camera1: {type: opencv, index_or_path: $CAMERA_1_PORT, width: 640, height: 480, fps: 30}, \
                       camera2: {type: opencv, index_or_path: $CAMERA_2_PORT, width: 640, height: 480, fps: 30} }" \
    --teleop.type=so101_leader \
    --teleop.port=/dev/ttyACM0 \
    --teleop.id=kevin \
    --display_data=true
    ```
    (assuming cameras/ports/calibration/naming has already been run and saved to .env)

### note:

initially the repo will be set up like:
```
this-repo/
├── so101.sh                <--
├── README
├── (.gitignore)
└── (.env)
```
but after installing lerobot, should be
```
this-repo/
├── lerobot/
│   ├── lerobot files...
│   └── so101.sh            <--
├── README.md
├── (.gitignore)
└── (.env)
```

### example .env if needed:
```env
HF_TOKEN=#insert-token-here
WANDB_TOKEN=#insert-token-here
FOLLOWER_PORT=/dev/ttyACM1
FOLLOWER_NAME=follower001
TELEOP_PORT=/dev/ttyACM0
TELEOP_NAME=leader_001
CAMERA_1_PORT=/dev/video10
CAMERA_2_PORT=/dev/video4
CAMERA_3_PORT=/dev/video6
CAMERA_4_PORT=/dev/video8
CONDA_INSTALLED=false
```
