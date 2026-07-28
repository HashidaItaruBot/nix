{
  config,
  pkgs,
  ...
}: {
  # 加载 ITE Super I/O 驱动，暴露主板风扇 PWM 控制
  boot.kernelModules = ["it87"];

  # 如果是较新的 Gigabyte AM5 主板，it87 可能不识别芯片 ID，
  # 需要强制指定。取消下面这行注释并替换为你的芯片 ID：
  # boot.extraModprobeConfig = ''
  #   options it87 force_id=0x8689
  # '';

  # 安装 lm_sensors 用于手动探测和查看传感器
  environment.systemPackages = with pkgs; [
    lm_sensors
  ];

  # （可选）如果后续要通过 fancontrol 自动控制风扇：
  # 1. 先运行 sudo sensors-detect 探测硬件
  # 2. 运行 sudo pwmconfig 生成 /etc/fancontrol 配置
  # 3. 取消下面注释启用 fancontrol 服务：
  #
  # services.fancontrol.enable = true;
  # services.fancontrol.config = ''
  #   INTERVAL=10
  #   FCTEMPS=hwmon3/device/pwm1=hwmon3/device/temp1_input
  #   FCFANS=hwmon3/device/pwm1=hwmon3/device/fan1_input
  #   MINTEMP=hwmon3/device/pwm1=30
  #   MAXTEMP=hwmon3/device/pwm1=70
  #   MINSTART=hwmon3/device/pwm1=150
  #   MINSTOP=hwmon3/device/pwm1=0
  #   MINPWM=hwmon3/device/pwm1=80
  #   MAXPWM=hwmon3/device/pwm1=255
  # '';
}
