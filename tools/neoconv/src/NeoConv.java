public class NeoConv {
    public static void main(String[] args) {
        Converter converter;
        if (args.length > 0 && args[0].contains(".bmp")) {
            converter = new Converter(args[0]);
            converter.writeImage("out.spr");
            converter.writePalette("out.pal");
        }
        else {
            System.out.println("Usage: NeoConv [file to convert].bmp");
        }
    }
}
