#!/bin/bash
set -e
cat <<EOF

============
== DIGITS ==
============

NVIDIA Release ${NVIDIA_DIGITS_VERSION} (build ${NVIDIA_BUILD_ID})
DIGITS Version ${DIGITS_VERSION}
EOF

case "${DIGITS_FRAMEWORK}" in
  caffe)      echo "NVIDIA Caffe Version ${CAFFE_VERSION}" ;;
  tensorflow) echo "Tensorflow Version ${TENSORFLOW_VERSION}" ;;
esac

echo
echo "Container image Copyright (c) 2020, NVIDIA CORPORATION.  All rights reserved."
echo "DIGITS Copyright (c) 2014-2019, NVIDIA CORPORATION. All rights reserved."

case "${DIGITS_FRAMEWORK}" in
  caffe)      echo "Caffe Copyright (c) 2014, 2015, The Regents of the University of California (Regents). All rights reserved." ;;
  tensorflow) echo "TensorFlow Copyright (c) 2017-2019, The TensorFlow Authors.  All rights reserved." ;;
esac

echo
echo "Various files include modifications (c) NVIDIA CORPORATION.  All rights reserved."
echo "NVIDIA modifications are covered by the license terms that apply to the underlying project or file."

if [[ "$(find -L /usr -name libcuda.so.1 2>/dev/null | grep -v "compat") " == " " || "$(ls /dev/nvidiactl 2>/dev/null) " == " " ]]; then
  echo
  echo "WARNING: The NVIDIA Driver was not detected.  GPU functionality will not be available."
  echo "   Use 'nvidia-docker run' to start this container; see"
  echo "   https://github.com/NVIDIA/nvidia-docker/wiki/nvidia-docker ."
else
  ( /usr/local/bin/checkSMVER.sh )
  DRIVER_VERSION=$(sed -n 's/^NVRM.*Kernel Module *\([0-9.]*\).*$/\1/p' /proc/driver/nvidia/version 2>/dev/null || true)
  if [[ ! "$DRIVER_VERSION" =~ ^[0-9]*.[0-9]*(.[0-9]*)?$ ]]; then
    echo "Failed to detect NVIDIA driver version."
  elif [[ "${DRIVER_VERSION%%.*}" -lt "${CUDA_DRIVER_VERSION%%.*}" ]]; then
    if [[ "${_CUDA_COMPAT_STATUS}" == "CUDA Driver OK" ]]; then
      echo
      echo "NOTE: Legacy NVIDIA Driver detected.  Compatibility mode ENABLED."
    else
      echo
      echo "ERROR: This container was built for NVIDIA Driver Release ${CUDA_DRIVER_VERSION%.*} or later, but"
      echo "       version ${DRIVER_VERSION} was detected and compatibility mode is UNAVAILABLE."
      echo
      echo "       [[${_CUDA_COMPAT_STATUS}]]"
      sleep 2
    fi
  fi
fi

if ! cat /proc/cpuinfo | grep flags | sort -u | grep avx >& /dev/null; then
  echo
  echo "ERROR: This container was built for CPUs supporting at least the AVX instruction set, but"
  echo "       the CPU detected was $(cat /proc/cpuinfo |grep "model name" | sed 's/^.*: //' | sort -u), which does not report"
  echo "       support for AVX.  An Illegal Instrution exception at runtime is likely to result."
  echo "       See https://en.wikipedia.org/wiki/Advanced_Vector_Extensions#CPUs_with_AVX ."
  sleep 2
fi

echo

if [[ $# -eq 0 ]]; then
  exec "/bin/bash"
else
  exec "$@"
fi
