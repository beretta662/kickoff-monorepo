import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kickoff_core/kickoff_core.dart';
import 'standings_controller.dart';

class StandingsScreen extends StatelessWidget {
  final String competitionId;
  const StandingsScreen({super.key, required this.competitionId});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(StandingsController(competitionId: competitionId), tag: competitionId);
    final palette = AppPalette.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Classement')),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.classement.isEmpty) {
          return Center(child: Text('Aucune équipe pour l\'instant.', style: AppTextStyles.bodySecondary(context)));
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // Largeur minimale pour que toutes les colonnes restent lisibles ;
                // en dessous, le tableau défile horizontalement.
                final largeur = constraints.maxWidth < 480 ? 480.0 : constraints.maxWidth;

                return SingleChildScrollView(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SizedBox(
                      width: largeur,
                      child: Table(
                        defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                        columnWidths: const {
                          0: FixedColumnWidth(32),
                          1: FlexColumnWidth(),
                          2: FixedColumnWidth(40),
                          3: FixedColumnWidth(40),
                          4: FixedColumnWidth(40),
                          5: FixedColumnWidth(40),
                          6: FixedColumnWidth(44),
                          7: FixedColumnWidth(44),
                          8: FixedColumnWidth(48),
                          9: FixedColumnWidth(48),
                        },
                        children: [
                          _enTete(context, palette),
                          ...List.generate(controller.classement.length, (index) {
                            return _ligne(context, palette, index, controller.classement[index]);
                          }),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }

  TableRow _enTete(BuildContext context, AppPalette palette) {
    Widget cellule(String texte, {TextAlign align = TextAlign.center, bool gras = false}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Text(
          texte,
          textAlign: align,
          style: AppTextStyles.caption(context).copyWith(fontWeight: gras ? FontWeight.w700 : null),
        ),
      );
    }

    return TableRow(
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: palette.border))),
      children: [
        cellule('#'),
        cellule('Équipe', align: TextAlign.left),
        cellule('J'),
        cellule('V'),
        cellule('N'),
        cellule('D'),
        cellule('BP'),
        cellule('BC'),
        cellule('DB'),
        cellule('Pts', gras: true),
      ],
    );
  }

  TableRow _ligne(BuildContext context, AppPalette palette, int index, EquipeClassement e) {
    final estLeader = index == 0;

    Widget cellule(String texte, {TextAlign align = TextAlign.center, TextStyle? style}) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(texte, textAlign: align, style: style ?? AppTextStyles.caption(context)),
      );
    }

    final db = e.differenceButs > 0 ? '+${e.differenceButs}' : '${e.differenceButs}';

    return TableRow(
      decoration: BoxDecoration(
        color: estLeader ? palette.background : null,
        border: Border(bottom: BorderSide(color: palette.border, width: 0.5)),
      ),
      children: [
        cellule(
          '${index + 1}',
          style: AppTextStyles.body(context).copyWith(
            color: estLeader ? AppColors.success : null,
            fontWeight: estLeader ? FontWeight.w600 : null,
          ),
        ),
        cellule(e.nom, align: TextAlign.left, style: AppTextStyles.body(context)),
        cellule('${e.joues}'),
        cellule('${e.victoires}'),
        cellule('${e.nuls}'),
        cellule('${e.defaites}'),
        cellule('${e.butsPour}'),
        cellule('${e.butsContre}'),
        cellule(db),
        cellule('${e.points}', style: AppTextStyles.body(context).copyWith(fontWeight: FontWeight.w700)),
      ],
    );
  }
}