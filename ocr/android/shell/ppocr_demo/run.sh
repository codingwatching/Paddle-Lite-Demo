#!/bin/bash
MODEL_NAME=PP-OCRv5_mobile
ASSETS_DIR="$(pwd)/../../../assets"
MODEL_LIST="PP-OCRv3_mobile PP-OCRv4_mobile PP-OCRv5_mobile"

if [ -n "$1" ]; then
  MODEL_NAME="$1"
fi

if ! echo "$MODEL_LIST" | grep -qw "$MODEL_NAME"; then
  echo "Supported models: ${MODEL_LIST}"
  echo "$MODEL_NAME is not in the supported models. Now exiting."
  exit 1
fi

if [ ! -f "${ASSETS_DIR}/models/${MODEL_NAME}_det.nb" ] && [ ! -f "./ppocr_demo/models/${MODEL_NAME}_det.nb" ];then
  echo "Model ${MODEL_NAME}_det not found! "
  exit 1
fi

if [ ! -f "${ASSETS_DIR}/models/${MODEL_NAME}_rec.nb" ] && [ ! -f "./ppocr_demo/models/${MODEL_NAME}_rec.nb" ];then
  echo "Model ${MODEL_NAME}_rec not found! "
  exit 1
fi

if [[ "$MODEL_NAME" == *"PP-OCRv5_mobile"* ]]; then
  CLS_MODEL_FILE="PP-LCNet_x0_25_textline_ori.nb"
  LABEL_FILE="ppocr_keys_ocrv5.txt"
else
  CLS_MODEL_FILE="ch_ppocr_mobile_v2.0_cls_slim_opt.nb"
  LABEL_FILE="ppocr_keys_v1.txt"
fi

# push
cp -r ../../../assets/config.txt ./ppocr_demo
cp -r ../../../assets/labels ./ppocr_demo
cp -r ../../../assets/images ./ppocr_demo
cp -r ../../../assets/models ./ppocr_demo

adb push ./ppocr_demo /data/local/tmp/
ppocr_demo_path="/data/local/tmp/ppocr_demo"

# run
adb shell "cd ${ppocr_demo_path} \
           && chmod +x ./ppocr_demo \
           && export LD_LIBRARY_PATH=${ppocr_demo_path}:${LD_LIBRARY_PATH} \
           && ./ppocr_demo \
                \"./models/${MODEL_NAME}_det.nb\" \
                \"./models/${MODEL_NAME}_rec.nb\" \
                ./models/${CLS_MODEL_FILE} \
                ./images/test.jpg \
                ./test_img_result.jpg \
                ./labels/${LABEL_FILE} \
                ./config.txt"

adb pull ${ppocr_demo_path}/test_img_result.jpg .
