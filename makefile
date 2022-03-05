EMBEDDED: hal.f arduino.f adc-hal.f timers.f lcd.f main.f
	rm -f embedded.f
	rm -f final.f
	cat hal.f >> embedded.f
	cat arduino.f >> embedded.f
	cat adc-hal.f >> embedded.f
	cat timers.f >> embedded.f
	cat lcd.f >> embedded.f
	cat main.f >> embedded.f
	grep -v '^ *\\' embedded.f > final.f
