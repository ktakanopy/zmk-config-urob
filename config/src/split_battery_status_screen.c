#include <zephyr/kernel.h>

#include <lvgl.h>

#include <zmk/battery.h>
#include <zmk/display.h>
#include <zmk/display/status_screen.h>
#include <zmk/display/widgets/layer_status.h>
#include <zmk/display/widgets/output_status.h>
#include <zmk/event_manager.h>
#include <zmk/events/battery_state_changed.h>

#if IS_ENABLED(CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_FETCHING)
#include <zmk/split/bluetooth/central.h>
#endif

static lv_obj_t *battery_label;

#if IS_ENABLED(CONFIG_ZMK_WIDGET_OUTPUT_STATUS)
static struct zmk_widget_output_status output_status_widget;
#endif

#if IS_ENABLED(CONFIG_ZMK_WIDGET_LAYER_STATUS)
static struct zmk_widget_layer_status layer_status_widget;
#endif

struct split_battery_state {
    uint8_t left;
    uint8_t right;
    bool right_connected;
};

static void update_battery_label(struct split_battery_state state) {
    char text[18];

    if (state.right_connected) {
        snprintf(text, sizeof(text), "L %3u%%\nR %3u%%", state.left, state.right);
    } else {
        snprintf(text, sizeof(text), "L %3u%%\nR  --", state.left);
    }

    lv_label_set_text(battery_label, text);
}

static struct split_battery_state get_battery_state(const zmk_event_t *eh) {
    struct split_battery_state state = {.left = zmk_battery_state_of_charge()};
    const struct zmk_battery_state_changed *local = as_zmk_battery_state_changed(eh);

    if (local != NULL) {
        state.left = local->state_of_charge;
    }

#if IS_ENABLED(CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_FETCHING)
    uint8_t right;
    if (zmk_split_get_peripheral_battery_level(0, &right) == 0) {
        state.right = right;
        state.right_connected = true;
    }
#endif

    return state;
}

ZMK_DISPLAY_WIDGET_LISTENER(split_battery_status, struct split_battery_state,
                            update_battery_label, get_battery_state)
ZMK_SUBSCRIPTION(split_battery_status, zmk_battery_state_changed);
#if IS_ENABLED(CONFIG_ZMK_SPLIT_BLE_CENTRAL_BATTERY_LEVEL_FETCHING)
ZMK_SUBSCRIPTION(split_battery_status, zmk_peripheral_battery_state_changed);
#endif

lv_obj_t *zmk_display_status_screen() {
    lv_obj_t *screen = lv_obj_create(NULL);

#if IS_ENABLED(CONFIG_ZMK_WIDGET_OUTPUT_STATUS)
    zmk_widget_output_status_init(&output_status_widget, screen);
    lv_obj_align(zmk_widget_output_status_obj(&output_status_widget), LV_ALIGN_TOP_LEFT, 0, 0);
#endif

    battery_label = lv_label_create(screen);
    lv_obj_align(battery_label, LV_ALIGN_TOP_RIGHT, 0, 0);
    split_battery_status_init();

#if IS_ENABLED(CONFIG_ZMK_WIDGET_LAYER_STATUS)
    zmk_widget_layer_status_init(&layer_status_widget, screen);
    lv_obj_set_style_text_font(zmk_widget_layer_status_obj(&layer_status_widget),
                               lv_theme_get_font_small(screen), LV_PART_MAIN);
    lv_obj_align(zmk_widget_layer_status_obj(&layer_status_widget), LV_ALIGN_BOTTOM_LEFT, 0, 0);
#endif

    return screen;
}
