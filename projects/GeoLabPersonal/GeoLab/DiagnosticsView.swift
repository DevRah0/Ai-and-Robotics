import SwiftUI
import CoreLocation

struct DiagnosticsView: View {
    @EnvironmentObject private var model: AppModel
    @EnvironmentObject private var gps: LocationService
    @State private var latest: TestEvaluation?

    var body: some View {
        ScrollView {
            VStack(alignment: .trailing, spacing: 20) {
                Text("فحص الموقع")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .padding(.top, 20)
                Text("مختبر للتحقق من قوة السياج الجغرافي باستخدام بيانات حقيقية أو محاكاة محلية — دون الاتصال بأي نظام حضور.")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                    .multilineTextAlignment(.trailing)

                SectionHeading(text: "قراءة CoreLocation")
                GeoCard {
                    VStack(alignment: .trailing, spacing: 12) {
                        ValueRow(label: "صلاحية الموقع", value: permissionText, symbol: "checkmark.shield")
                        Divider()
                        if let location = gps.location {
                            ValueRow(label: "خط العرض", value: location.coordinate.latitude.coordinateString)
                            Divider()
                            ValueRow(label: "خط الطول", value: location.coordinate.longitude.coordinateString)
                            Divider()
                            ValueRow(label: "الدقة الفعلية", value: "±\(Int(location.horizontalAccuracy)) متر")
                            Divider()
                            ValueRow(label: "عمر القراءة", value: "\(Int(max(0, -location.timestamp.timeIntervalSinceNow))) ثانية")
                            Divider()
                            ValueRow(label: "محاكاة برمجية", value: simSourceText(location))
                            Divider()
                            ValueRow(label: "ملحق خارجي", value: accessoryText(location))
                        } else {
                            Text("لم تصل قراءة GPS بعد. فعّل صلاحية الموقع وأعد المحاولة.")
                                .foregroundStyle(.secondary)
                            Button("طلب إذن الموقع") { gps.requestPermission() }
                        }
                    }
                }

                SectionHeading(text: "اختبار سياج جغرافي محلي")
                GeoCard {
                    VStack(alignment: .trailing, spacing: 13) {
                        Text("مركز النطاق هو النقطة التي اخترتها على الخريطة.")
                            .font(.caption).foregroundStyle(.secondary)
                        ValueRow(label: "المركز", value: "\(model.selectedCoordinate.latitude.coordinateString), \(model.selectedCoordinate.longitude.coordinateString)")
                        Divider()
                        HStack {
                            Text("\(Int(model.radius)) متر").foregroundStyle(Color.geoDeep)
                            Spacer()
                            Text("نصف قطر السماح")
                        }
                        Slider(value: $model.radius, in: 25...1000, step: 25)
                        Toggle("رفض الموقع الموسوم بمحاكاة برمجية", isOn: $model.rejectSimulated)
                        Text(model.previewIsOn ? "مصدر الاختبار: الإحداثيات النموذجية داخل التطبيق" : "مصدر الاختبار: CoreLocation الحقيقي")
                            .font(.caption).foregroundStyle(.secondary)
                        PrimaryButton(title: "تشغيل الاختبار", symbol: "checkmark.shield.fill") {
                            latest = model.runTest(location: gps.location)
                        }
                        if let latest {
                            HStack(spacing: 10) {
                                Image(systemName: latest.accepted ? "checkmark.circle.fill" : "xmark.octagon.fill")
                                    .font(.title2)
                                    .foregroundStyle(latest.accepted ? .green : .orange)
                                VStack(alignment: .trailing, spacing: 5) {
                                    Text(latest.accepted ? "مقبول محليًا" : "مرفوض محليًا")
                                        .font(.headline)
                                    Text(latest.reason).font(.caption)
                                    Text("المسافة \(Int(latest.distance)) متر")
                                        .font(.caption).foregroundStyle(.secondary)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .padding(12)
                            .background(Color.geoBackground, in: RoundedRectangle(cornerRadius: 13))
                        }
                    }
                }

                HStack {
                    if !model.records.isEmpty {
                        ShareLink(item: model.exportJSON(), subject: Text("GeoLab - نتائج الاختبار")) {
                            Label("مشاركة سجل JSON", systemImage: "square.and.arrow.up")
                                .font(.subheadline.weight(.semibold))
                        }
                    }
                    Spacer()
                    SectionHeading(text: "سجل الاختبارات (\(model.records.count))")
                }
                ForEach(model.records.prefix(12)) { record in
                    GeoCard {
                        HStack {
                            Image(systemName: record.accepted ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .foregroundStyle(record.accepted ? .green : .orange)
                            Spacer()
                            VStack(alignment: .trailing, spacing: 4) {
                                Text(record.scenario).font(.subheadline.weight(.semibold))
                                Text(record.details).font(.caption).foregroundStyle(.secondary)
                                Text(record.date, format: .dateTime.day().month().hour().minute())
                                    .font(.caption2).foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                if model.records.isEmpty {
                    Text("لا توجد اختبارات بعد")
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 30)
        }
    }

    private var permissionText: String {
        switch gps.authorization {
        case .authorizedWhenInUse: return "مسموح أثناء الاستخدام"
        case .authorizedAlways: return "مسموح دائمًا"
        case .denied: return "مرفوض"
        case .restricted: return "مقيّد"
        case .notDetermined: return "لم يُطلب بعد"
        @unknown default: return "غير معروف"
        }
    }

    private func simSourceText(_ location: CLLocation) -> String {
        guard let source = location.sourceInformation else { return "غير متاح من iOS" }
        return source.isSimulatedBySoftware ? "نعم (وفق علم النظام)" : "لا (وفق علم النظام)"
    }

    private func accessoryText(_ location: CLLocation) -> String {
        guard let source = location.sourceInformation else { return "غير متاح" }
        return source.isProducedByAccessory ? "نعم" : "لا"
    }
}
