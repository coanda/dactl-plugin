namespace Dactl.SinamicsS {
    public enum ChannelType {
        SPEED,
        SPEEDSET,
        TORQUE,
        POSITION,
        VIBRATION,
        GENERIC
    }

    public class Channel {
        public Cld.AIChannel cld_channel;
        public int type;
        public int pvalue;
    }

    public errordomain Error {
        CONNECTION,
        CONNECTION_FAILED,
        NO_ACTIVE_PLC,
        NO_CONNECTION,
        MODBUS_TIMEOUT,
        MODBUS_ERROR,
    }

    public async void nap (uint interval, int priority = GLib.Priority.DEFAULT) {
        GLib.Timeout.add (interval, () => {
            nap.callback ();
            return false;
        }, priority);
        yield;
    }
}
