require 'test_helper'
class RecordsControllerTest < ActionController::TestCase
  include Devise::Test::ControllerHelpers

  setup do
    FactoryBot.create(:admin_user)
    FactoryBot.create(:atl_user)
    FactoryBot.create(:user_user)
    vendor_user = FactoryBot.create(:vendor_user)
    FactoryBot.create(:other_user)
    @bundle = FactoryBot.create(:static_bundle)
    @patient_id = @bundle.fhir_patient_bundles.first.id

    add_user_to_vendor(vendor_user, FactoryBot.create(:vendor_static_name))
  end

  test 'should redirect from index to default bundle' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :index
      assert_redirected_to bundle_records_path(Bundle.default)
    end
  end

  test 'should not crash when no bundles' do
    Bundle.all.destroy
    for_each_logged_in_user([ADMIN]) do
      get :index
      assert_response :success
    end
  end

  test 'should get index scoped to bundle' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :index, params: { bundle_id: @bundle.id }
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:patients)
      assert assigns(:source)
      assert assigns(:bundle)
    end
  end

  test 'should get show' do
    # do this for all users
    for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
      get :show, params: { id: @patient_id }
      assert_response :success, "#{@user.email} should have access "
      assert assigns(:record)
    end
  end

  # TODO: Bring back filter by measure
  # test 'should get patients by measure' do
  #   # do this for all users
  #   for_each_logged_in_user([ADMIN, ATL, OWNER, VENDOR, OTHER_VENDOR]) do
  #     get :index
  #     get :by_measure, xhr: true, params: { measure_id: @bundle.fhir_measure_bundles.first.hqmf_id, bundle_id: @bundle.id }
  #     assert_template :by_measure
  #     assert_response :success, "#{@user.email} should have access to bundle patients by measure"
  #     assert assigns(:patients)
  #     assert assigns(:source)
  #     assert assigns(:bundle)
  #   end
  # end
end
