import 'package:flutter/material.dart';

import 'package:otraku/constants/consts.dart';

class ThemePreview extends StatelessWidget {
  const ThemePreview({
    Key? key,
    required this.name,
    required this.scheme,
    required this.active,
    required this.onTap,
  }) : super(key: key);

  final String name;
  final ColorScheme scheme;
  final bool active;
  final void Function(String name) onTap;

  @override
  Widget build(BuildContext context) {
     Color borderColor = active ? Theme.of(context).colorScheme.primary : scheme.inverseSurface;
     double borderWidth = active ? 2 : 1;

    return GestureDetector(
      onTap: () => onTap(name),
      child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: 120,
                height: 180,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                    color: scheme.background,
                    border: Border.all(color: borderColor, width: borderWidth),
                    borderRadius: Consts.borderRadiusMin),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                              height: 10,
                              width: 60,
                              decoration: BoxDecoration(
                                  color: scheme.onBackground,
                                  borderRadius: Consts.borderRadiusMax)),
                          SizedBox(height: 10),
                          Container(
                            height: 40,
                            decoration: BoxDecoration(
                                color: scheme.surface,
                                borderRadius: Consts.borderRadiusMin),
                            child: Padding(
                              padding: const EdgeInsets.all(5),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      height: 8,
                                      width: 40,
                                      decoration: BoxDecoration(
                                          color: scheme.surfaceVariant,
                                          borderRadius:
                                              Consts.borderRadiusMax)),
                                  SizedBox(height: 5),
                                  Container(
                                      height: 6,
                                      width: 110,
                                      decoration: BoxDecoration(
                                          color: scheme.onSurface,
                                          borderRadius:
                                              Consts.borderRadiusMax)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: Container()),
                    Container(
                      height: 20,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle)),
                          Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.rectangle)),
                          Container(
                              height: 8,
                              width: 8,
                              decoration: BoxDecoration(
                                  color: scheme.primary,
                                  shape: BoxShape.circle))
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Text(name, style: Theme.of(context).textTheme.bodyText2)
            ],
          )),
    );
  }
}
