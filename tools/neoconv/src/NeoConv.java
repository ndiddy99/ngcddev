public class NeoConv {
    public static void main(String[] args) {
        Converter converter;
        if (args.length > 0 && args[0].contains(".bmp")) {
            converter = new Converter(args[0]);
        }
        else {
            System.out.println("Usage: NeoConv [file to convert].bmp");
        }
    }
}
