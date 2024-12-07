import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:test_app/src/rust/api/simple.dart';
import 'package:test_app/src/rust/frb_generated.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:hexcolor/hexcolor.dart';
import 'package:flutter_markdown_latex/flutter_markdown_latex.dart';
import 'package:test_app/src/rust/api/openai/chat.dart';

class Message {
  final String text;
  final bool isSentByMe;

  const Message({
    required this.text,
    required this.isSentByMe,
  });
}

List<Message> messages = [
  Message(
    text: "Welcome 😍 \n [DEMO]",
    isSentByMe: false
  ),
];

class Chat extends StatefulWidget {
  const Chat({ super.key });

  @override
  State<Chat> createState() => _Chat();
}

class _Chat extends State<Chat> {
    
  TextEditingController _controller = TextEditingController();  // Controller for TextField
  String chatLog = "";
  FocusNode _focusNode = FocusNode();
  bool api = true;
  String apiKeys = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar(),
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(0),
                color: HexColor('#222831')
              ),
              child: GroupedListView<Message, DateTime>(
                padding: const EdgeInsets.all(10),
                elements: messages,
                groupBy: (message) => DateTime(2024),
                groupHeaderBuilder: (Message message) => SizedBox(),
                itemBuilder: (context, Message message) => Align(
                  alignment: message.isSentByMe
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                  child: Card(
                    color: message.isSentByMe
                      ? HexColor('#C7C8CC')
                      : HexColor('#31363F'),
                    margin: message.isSentByMe
                      ? EdgeInsets.only(left: 42, top: 10, bottom: 10, right: 10)
                      : EdgeInsets.only(right: 42, top: 10, bottom: 10, left: 10),
                    elevation:10,
                    child: Container(
                      padding: const EdgeInsets.all(13),
                      child: MarkdownBody(
                        selectable: true,
                        styleSheet:
                          MarkdownStyleSheet.fromTheme(
                            ThemeData(
                              textTheme: TextTheme(
                                bodyMedium: TextStyle(
                                  fontSize: 14,
                                  fontWeight: message.isSentByMe
                                    ? FontWeight.w400
                                    : FontWeight.w300,
                                  color: message.isSentByMe
                                    ? HexColor('#000')
                                    : HexColor('#EEEEEE'),
                                )
                              ) 
                            ),
                        ).copyWith(
                          codeblockDecoration: 
                            BoxDecoration (
                              color: HexColor('#222831'),
                              borderRadius: BorderRadius.circular(10)
                            ),
                          code: TextStyle (
                              fontSize: 12,
                              color: HexColor('#76ABAE'),
                          ),
                          h1: TextStyle(color: HexColor('#EEEEEE')), 
                          h2: TextStyle(color: HexColor('#EEEEEE')), 
                          h3: TextStyle(color: HexColor('#EEEEEE')), 
                        ),
                        data: message.text,
                        builders: {
                          'latex' : LatexElementBuilder(
                            textStyle: TextStyle(color: HexColor('#76ABAE'))
                          ),
                        },
                        extensionSet: md.ExtensionSet(
                        [
                          ...[LatexBlockSyntax()],
                          ...md.ExtensionSet.gitHubFlavored.blockSyntaxes,
                        ],
                        [
                          ...<md.InlineSyntax>[
                            md.EmojiSyntax(),
                            ...md.ExtensionSet.gitHubFlavored.inlineSyntaxes
                          ],
                        ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            color: HexColor('#222831'),
            child: Container(
              margin: EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 10),
              child: TextField(
                controller: _controller,
                style: TextStyle(fontSize: 14),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: HexColor('#EEEEEE'),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
                  hintText: "Hva tenker du på?",
                ),
                keyboardType: TextInputType.multiline,
                minLines: 1,
                maxLines: 5,
                textInputAction: TextInputAction.done,
                onSubmitted: (text)  async{   
                  _controller.clear();
                  if (api) {
                    apiKeys = text;
                    api = false;
                  }
                  String response = await chat(input: text); 
                  setState(() {
                    messages.add(
                      Message(
                        text: text, 
                        isSentByMe: true,
                      ),
                    );
                    messages.add(
                      Message(
                        text: response,
                        isSentByMe: false,
                      ),
                    );
                  });
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

AppBar appBar() {
  return AppBar(
    title: const Text(
      "Ch.AI",
      style: TextStyle(
        color: Colors.amberAccent,
        fontSize: 18,
        fontWeight: FontWeight.w800
      ),
    ),
    elevation: 0,
    centerTitle: false,
    backgroundColor: HexColor('#222831'),
    leading: GestureDetector(
      onTap: () {
        
        
      },
      child: Container(
        margin: const EdgeInsets.all(10),
        alignment: Alignment.center,
        child: SvgPicture.asset('assets/icons/stack.svg'),
        decoration: BoxDecoration(
          color: Colors.amberAccent,
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    ),
  );
}


